#!/usr/bin/env node
/**
 * Seeds CloseMap demo data into Firebase (closemap-app).
 * Auth: firebase login OR GOOGLE_APPLICATION_CREDENTIALS service account.
 *
 * Usage:
 *   npm install && npm run seed
 *   npm run seed:wipe
 */
import { readFileSync, existsSync, writeFileSync } from 'fs';
import { homedir, tmpdir } from 'os';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import admin from 'firebase-admin';

const __dirname = dirname(fileURLToPath(import.meta.url));
const seedPath = join(__dirname, '..', 'seed', 'seed_data.json');
const data = JSON.parse(readFileSync(seedPath, 'utf8'));

const args = process.argv.slice(2);
const projectIdx = args.indexOf('--project');
const projectId = projectIdx >= 0 ? args[projectIdx + 1] : 'closemap-app';
const wipe = args.includes('--wipe');

const FIREBASE_CLI_CLIENT_ID =
  '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const FIREBASE_CLI_CLIENT_SECRET = 'j9iVZfS8kkCEFUPaAeJV0sAi';

function tsFromNow({ days = 0, hours = 0 }) {
  const d = new Date();
  d.setDate(d.getDate() + days);
  d.setHours(d.getHours() + hours);
  return admin.firestore.Timestamp.fromDate(d);
}

function initFirebaseAdmin(projectId) {
  const localKey = join(__dirname, 'serviceAccountKey.json');
  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS && existsSync(localKey)) {
    process.env.GOOGLE_APPLICATION_CREDENTIALS = localKey;
  }
  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    const cfgPath = join(homedir(), '.config', 'configstore', 'firebase-tools.json');
    if (!existsSync(cfgPath)) {
      throw new Error(
        'Run `firebase login`, place serviceAccountKey.json in tools/, or set GOOGLE_APPLICATION_CREDENTIALS.',
      );
    }
    const cfg = JSON.parse(readFileSync(cfgPath, 'utf8'));
    const adc = {
      type: 'authorized_user',
      client_id: cfg.user?.aud || FIREBASE_CLI_CLIENT_ID,
      client_secret: FIREBASE_CLI_CLIENT_SECRET,
      refresh_token: cfg.tokens.refresh_token,
    };
    const adcPath = join(tmpdir(), 'closemap-firebase-adc.json');
    writeFileSync(adcPath, JSON.stringify(adc));
    process.env.GOOGLE_APPLICATION_CREDENTIALS = adcPath;
  }
  admin.initializeApp({
    projectId,
    credential: admin.credential.applicationDefault(),
  });
}

async function ensureAuthUser(auth, email, password, displayName) {
  try {
    const existing = await auth.getUserByEmail(email);
    await auth.updateUser(existing.uid, {
      password,
      emailVerified: true,
      displayName,
    });
    return existing.uid;
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
    const created = await auth.createUser({
      email,
      password,
      emailVerified: true,
      displayName,
    });
    return created.uid;
  }
}

async function wipeDemo(db, auth, emails) {
  console.log('Wiping demo collections...');
  const collections = [
    'users',
    'seekerProfiles',
    'employerProfiles',
    'jobs',
    'applications',
    'savedJobs',
    'matchedJobs',
    'viewRequests',
    'exploringSpots',
    'transactions',
    'leaderboard',
  ];
  for (const col of collections) {
    const snap = await db.collection(col).get();
    const batch = db.batch();
    snap.docs.forEach((d) => batch.delete(d.ref));
    if (snap.size) await batch.commit();
  }
  for (const email of emails) {
    try {
      const u = await auth.getUserByEmail(email);
      await auth.deleteUser(u.uid);
    } catch (_) {}
  }
  for (const email of emails) {
    const notifSnap = await db.collection('notifications').get();
    for (const doc of notifSnap.docs) {
      const items = await doc.ref.collection('items').get();
      const batch = db.batch();
      items.docs.forEach((d) => batch.delete(d.ref));
      if (items.size) await batch.commit();
    }
  }
}

async function main() {
  initFirebaseAdmin(projectId);
  const db = admin.firestore();
  const auth = admin.auth();
  const emails = data.accounts.map((a) => a.email);

  if (wipe) await wipeDemo(db, auth, emails);

  console.log(`Seeding project ${projectId}...`);

  // Catalog
  for (const [id, plan] of Object.entries(data.plans)) {
    await db.collection('plans').doc(id).set(plan, { merge: true });
  }
  for (const [id, pkg] of Object.entries(data.pointPackages)) {
    await db.collection('pointPackages').doc(id).set(pkg, { merge: true });
  }
  for (const [id, values] of Object.entries(data.lookups)) {
    await db.collection('lookups').doc(id).set({ values }, { merge: true });
  }

  const defaultPrefs = data.defaultNotificationPrefs ?? {
    pushType1: true,
    pushType2: false,
    pushType3: false,
    emailOnMatch: false,
  };
  for (const entry of data.leaderboard ?? []) {
    const { id, ...doc } = entry;
    await db.collection('leaderboard').doc(String(id)).set(doc, { merge: true });
  }

  const uidByEmail = {};
  for (const acc of data.accounts) {
    const displayName =
      acc.role === 'employer'
        ? acc.companyName
        : acc.role === 'admin'
          ? `${acc.firstName} ${acc.lastName}`.trim() || 'Admin'
          : `${acc.firstName} ${acc.lastName}`;
    const uid = await ensureAuthUser(
      auth,
      acc.email,
      data.demoPassword,
      displayName,
    );
    uidByEmail[acc.email] = uid;

    const expiry = tsFromNow({ days: acc.subscriptionDays ?? 30 });
    await db
      .collection('users')
      .doc(uid)
      .set(
        {
          role: acc.role,
          firstName: acc.firstName ?? '',
          lastName: acc.lastName ?? '',
          companyName: acc.companyName ?? '',
          email: acc.email,
          phone: acc.phone ?? '',
          emailVerified: true,
          profileCompleted: true,
          language: acc.language ?? 'en',
          points: acc.points ?? 0,
          tier: acc.tier ?? 'none',
          subscriptionExpiry: expiry,
          latestJobTitle: acc.latestJobTitle ?? '',
          notificationPrefs: acc.notificationPrefs ?? defaultPrefs,
          createdAt: tsFromNow({ days: -30 }),
        },
        { merge: true },
      );

    if (acc.seekerProfile) {
      const sp = { ...acc.seekerProfile, uid, updatedAt: admin.firestore.FieldValue.serverTimestamp() };
      await db.collection('seekerProfiles').doc(uid).set(sp, { merge: true });
    }
    if (acc.employerProfile) {
      const ep = { ...acc.employerProfile, uid, updatedAt: admin.firestore.FieldValue.serverTimestamp() };
      await db.collection('employerProfiles').doc(uid).set(ep, { merge: true });
    }

    await db.collection('loginAttempts').doc(acc.email.toLowerCase()).delete();
  }

  const jobIds = {};
  for (const [key, job] of Object.entries(data.jobKeys)) {
    const employerId = uidByEmail[job.employerEmail];
    const employer = data.accounts.find((a) => a.email === job.employerEmail);
    const now = new Date();
    let publishedAt = now;
    let expiresAt = new Date(now);
    expiresAt.setDate(expiresAt.getDate() + (job.validityDays ?? 7));
    if (job.expiredDaysAgo) {
      expiresAt = new Date(now);
      expiresAt.setDate(expiresAt.getDate() - job.expiredDaysAgo);
      publishedAt = new Date(expiresAt);
      publishedAt.setDate(publishedAt.getDate() - job.validityDays);
    }
    const requiredSkills = job.requiredSkills ?? job.skills ?? [];
    const doc = {
      employerId,
      companyName: employer?.companyName ?? '',
      companyLogoUrl: employer?.employerProfile?.logoUrl ?? '',
      title: job.title,
      experienceLevel: 'Mid-Level',
      yearsOfExperience: 5,
      skills: requiredSkills,
      requiredSkills,
      languages: job.languages ?? ['English'],
      fieldOfEducation: job.fieldOfEducation ?? '',
      levelOfEducation: "Bachelor's Degree",
      jobType: 'Full-Time',
      remoteOption: 'Hybrid',
      salaryMin: 20000,
      salaryMax: 30000,
      currency: 'SR',
      genderType: 'All',
      joiningDate: admin.firestore.Timestamp.fromDate(
        new Date(now.getFullYear(), now.getMonth(), now.getDate() + 30),
      ),
      about:
        job.about ??
        `We are looking for a talented ${job.title} to join our growing team in Riyadh.`,
      duties: [
        `Lead day-to-day responsibilities for the ${job.title} role`,
        'Collaborate with cross-functional teams',
        'Deliver high-quality outcomes on schedule',
        'Contribute to continuous improvement initiatives',
      ].join('\n'),
      benefits: job.benefits ?? ['Health Insurance', 'Annual Leave'],
      locationText: 'Riyadh',
      city: 'Riyadh',
      country: 'Saudi Arabia',
      lat: job.lat,
      lng: job.lng,
      geohash: 'th3hw',
      validityDays: job.validityDays ?? 7,
      status: job.status ?? 'active',
      applicantsCount: job.applicantsCount ?? 0,
      publishedAt: job.status === 'draft' ? null : admin.firestore.Timestamp.fromDate(publishedAt),
      expiresAt: job.status === 'draft' ? null : admin.firestore.Timestamp.fromDate(expiresAt),
      createdAt: admin.firestore.Timestamp.fromDate(publishedAt),
    };
    await db.collection('jobs').doc(key).set(doc, { merge: true });
    jobIds[key] = key;
  }

  const sarahId = uidByEmail['sarah.seeker@closemap.demo'];
  const omarId = uidByEmail['omar.seeker@closemap.demo'];
  const techId = uidByEmail['techcorp@closemap.demo'];

  await db.collection('applications').doc('app_sarah_ux').set({
    jobId: 'job_ux_active',
    seekerId: sarahId,
    employerId: techId,
    jobTitle: 'UX/UI Designer',
    companyName: 'TechCorp Solutions',
    seekerName: 'Sarah Al-Harbi',
    status: 'pending',
    appliedAt: tsFromNow({ days: -1 }),
    removedBySeeker: false,
  });
  await db.collection('applications').doc('app_omar_eng').set({
    jobId: 'job_engineer_active',
    seekerId: omarId,
    employerId: techId,
    jobTitle: 'Software Engineer',
    companyName: 'TechCorp Solutions',
    seekerName: 'Omar Khalid',
    status: 'viewed',
    appliedAt: tsFromNow({ days: -2 }),
    removedBySeeker: false,
  });

  await db.collection('savedJobs').doc('saved_sarah_nurse').set({
    seekerId: sarahId,
    jobId: 'job_nurse_active',
    savedAt: tsFromNow({ days: -1 }),
  });

  await db.collection('matchedJobs').doc('match_sarah_eng').set({
    seekerId: sarahId,
    jobId: 'job_engineer_active',
    spotId: 'spot_sarah_1',
    score: 0.42,
    matchedAt: tsFromNow({ days: -1 }),
  });

  await db.collection('exploringSpots').doc('spot_sarah_1').set({
    seekerId: sarahId,
    name: 'Riyadh Center',
    lat: 24.7136,
    lng: 46.6753,
    radiusKm: 5,
    createdAt: tsFromNow({ days: -5 }),
  });

  await db.collection('viewRequests').doc('vr_pending').set({
    employerId: techId,
    seekerId: omarId,
    companyName: 'TechCorp Solutions',
    jobId: 'job_ux_active',
    jobTitle: 'UX/UI Designer',
    status: 'pending',
    createdAt: tsFromNow({ hours: -2 }),
    reminded: false,
  });
  await db.collection('viewRequests').doc('vr_approved_headhunt').set({
    employerId: techId,
    seekerId: sarahId,
    companyName: 'TechCorp Solutions',
    jobId: '',
    jobTitle: 'Headhunting',
    status: 'approved',
    createdAt: tsFromNow({ days: -3 }),
    respondedAt: tsFromNow({ days: -2 }),
    reminded: false,
  });

  await db.collection('transactions').doc('tx_sarah_sub').set({
    userId: sarahId,
    type: 'subscription',
    description: 'Silver plan',
    amount: 99,
    currency: 'SR',
    createdAt: tsFromNow({ days: -10 }),
  });

  const notifications = [
    { uid: sarahId, subject: 'New match', body: 'Software Engineer matches your spot', route: '/applications' },
    { uid: techId, subject: 'New applicant', body: 'Sarah applied to UX/UI Designer', route: '/employer/job/job_ux_active/applicants' },
    { uid: omarId, subject: 'Profile request', body: 'TechCorp requested your profile', route: '/applications' },
  ];
  for (const [i, n] of notifications.entries()) {
    await db.collection('notifications').doc(n.uid).collection('items').doc(`demo_${i}`).set({
      subject: n.subject,
      body: n.body,
      route: n.route,
      routeParams: {},
      read: false,
      createdAt: tsFromNow({ hours: -i - 1 }),
    });
  }

  console.log('\nSeed complete!\n');
  console.log('Demo password:', data.demoPassword);
  console.log('\nAccounts:');
  for (const acc of data.accounts) {
    console.log(`  ${acc.role.padEnd(8)} ${acc.email}`);
  }
  console.log('\nJobs:', Object.keys(jobIds).join(', '));
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
