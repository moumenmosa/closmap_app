# CloseMap

CloseMap is a location-based job marketplace mobile app built with **Flutter** and **Firebase (Spark plan)**.
Job seekers discover nearby jobs on an interactive map, apply using a points-based subscription system, and
employers post jobs, manage applicants, and headhunt nearby talent.

![CloseMap logo](assets/images/logo.png)

## Features

| Area | Capabilities |
|---|---|
| Registration & Login | Job seeker + employer registration, Firebase email verification link, login with lockout (5 attempts / 15 min), biometric login, password reset, EN/AR language toggle |
| Job Seeker Profile | Profile wizard (personal info, education, experience, languages, skills, resume PDF, links), view & edit |
| Employer Profile | Company details, logo/cover upload, registration certificate, HQ location on map |
| Home Page | Interactive map (OpenStreetMap) with clustered job & company markers, list view sorted by proximity, company profiles |
| Search & Filter | Keyword search, suggestions, advanced filters, map/list results |
| Jobs Application | Apply with points + subscription geo-scope, applied/saved/matched tabs, profile-view requests approve/reject |
| Jobs Management | Add job post wizard (drafts, validity period, map location), posted jobs list with status filters, applicants management with matching candidates |
| Exploring Spots | Define spots (1–15 km radius) that drive the job matching engine |
| Subscriptions | Bronze / Silver / Gold plans, points store, transaction history (mock payment) |
| Notifications | In-app notification center grouped by date + local notifications |

## Architecture

- **Flutter** (Android / iOS), Riverpod, go_router, full EN/AR localization with RTL.
- **Firebase Spark**: Auth (email/password) + Cloud Firestore. No Cloud Functions are used, so all
  business logic is client-side and guarded by `firestore.rules`.
- **flutter_map + OpenStreetMap** — free map tiles, no API key required.
- **Cloudinary** (free tier) — profile images, company logos/covers, certificates and CV PDFs.
- **Firebase Auth email** (Spark plan) — sends verification and password-reset emails at no extra cost.

## One-time setup

### 1. Firebase (Spark plan — free)

This repo is wired to Firebase project **`closemap-app`** ([console](https://console.firebase.google.com/project/closemap-app/overview)).

Already configured:

- Android app `com.closemap.closemap` → `android/app/google-services.json`
- iOS app `com.closemap.closemap` → `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart` (via FlutterFire)
- Firestore database `(default)` in **europe-west1**
- Firestore security rules + indexes deployed
- **Email/Password** authentication enabled

To redeploy rules/indexes from this machine:

```bash
firebase deploy --only firestore:rules,firestore:indexes --project closemap-app
```

### Demo data seed

Full demo dataset (accounts, jobs, applications, spots, notifications):

```bash
cd tools
npm install
npm run seed
# optional wipe first: npm run seed:wipe
```

Demo accounts (password `Demo1234!`):

| Role | Email |
|------|-------|
| Admin | admin@closemap.demo |
| Seeker | sarah.seeker@closemap.demo |
| Seeker | omar.seeker@closemap.demo |
| Employer | techcorp@closemap.demo |
| Employer | healthco@closemap.demo |

Catalog-only seed (plans, packages, lookups) from the debug login button may fail due to Firestore rules — use the admin script above instead.

### 2. Cloudinary (free tier)

1. Create an account at [cloudinary.com](https://cloudinary.com) — the free tier is plenty.
2. In **Settings → Upload → Upload presets**, create an **unsigned** preset named `closemap_unsigned` (Signing mode: **Unsigned**).
3. The cloud name is already set in [`lib/core/config/app_config.dart`](lib/core/config/app_config.dart) (`ddoknf9ir`). Do **not** put your API secret in the mobile app.

### 3. Email verification (Firebase Spark)

Verification emails are sent automatically via `FirebaseAuth.sendEmailVerification()` after registration.
Customize the sender and template under **Firebase Console → Authentication → Templates**.
Password reset uses the same Firebase email system (`sendPasswordResetEmail`).

## Running

```bash
flutter pub get
flutter run
```

## Project structure

```
lib/
  core/            # config, theme, router, services, shared widgets, utils
  features/
    auth/          # registration, OTP, login, password reset
    seeker_profile/
    employer_profile/
    home/          # map + list home for both roles
    jobs/          # job details, company profile
    applications/  # applied / saved / matched / requests
    employer_jobs/ # job post wizard, posted jobs, applicants
    spots/         # exploring spots
    subscriptions/ # plans, points store, transactions
    notifications/
  l10n/            # app_en.arb, app_ar.arb
firestore.rules
firestore.indexes.json
seed/seed_data.json
```

## Spark-plan design notes

- **OTP emails** are sent client-side via EmailJS; codes are stored hashed in Firestore with a 60s resend timer and 5-attempt limit.
- **Notifications** are Firestore documents; realtime listeners raise local notifications while the app runs (no FCM server available on Spark).
- **Payments** are mocked — the Pay Now flow records a transaction document without charging anything.
- **Job expiry** is enforced at query time (`expiresAt` filter) since scheduled functions are unavailable.
