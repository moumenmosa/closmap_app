import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';
import '../models/app_user.dart';

class AuthService {
  AuthService(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> _checkLockout(String email) async {
    final doc = await _db.collection('loginAttempts').doc(email.toLowerCase()).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final lockedUntil = (data['lockedUntil'] as Timestamp?)?.toDate();
    if (lockedUntil != null && lockedUntil.isAfter(DateTime.now())) {
      throw Exception('account_locked');
    }
  }

  Future<void> _recordFailedAttempt(String email) async {
    final ref = _db.collection('loginAttempts').doc(email.toLowerCase());
    final snap = await ref.get();
    var attempts = 1;
    if (snap.exists) {
      final lockedUntil = (snap.data()?['lockedUntil'] as Timestamp?)?.toDate();
      if (lockedUntil != null && lockedUntil.isAfter(DateTime.now())) {
        throw Exception('account_locked');
      }
      attempts = ((snap.data()?['attempts'] ?? 0) as int) + 1;
    }
    await ref.set({
      'attempts': attempts,
      'lockedUntil': attempts >= AppConfig.maxLoginAttempts
          ? Timestamp.fromDate(
              DateTime.now().add(Duration(minutes: AppConfig.loginLockoutMinutes)),
            )
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _clearAttempts(String email) async {
    await _db.collection('loginAttempts').doc(email.toLowerCase()).delete();
  }

  Future<AppUser> signIn(String email, String password) async {
    await _checkLockout(email);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _clearAttempts(email);
      await cred.user!.reload();
      final firebaseUser = _auth.currentUser;
      var user = await getUser(cred.user!.uid);
      if (user == null) throw Exception('user_not_found');
      if (firebaseUser?.emailVerified == true && !user.emailVerified) {
        await markEmailVerified(user.uid);
        user = (await getUser(user.uid))!;
      }
      if (!user.emailVerified) throw Exception('email_not_verified');
      return user;
    } on FirebaseAuthException {
      await _recordFailedAttempt(email);
      rethrow;
    }
  }

  Future<AppUser> registerSeeker({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user!.uid;
    final user = AppUser(
      uid: uid,
      role: UserRole.seeker,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(uid).set(user.toMap());
    await _db.collection('seekerProfiles').doc(uid).set({'uid': uid});
    return user;
  }

  Future<AppUser> registerEmployer({
    required String email,
    required String password,
    required String companyName,
    required String phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user!.uid;
    final user = AppUser(
      uid: uid,
      role: UserRole.employer,
      companyName: companyName.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(uid).set(user.toMap());
    await _db.collection('employerProfiles').doc(uid).set({
      'uid': uid,
      'companyName': companyName.trim(),
    });
    return user;
  }

  Future<void> markEmailVerified(String uid) async {
    await _db.collection('users').doc(uid).update({'emailVerified': true});
  }

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('not_signed_in');
    if (user.emailVerified) return;
    await user.sendEmailVerification();
  }

  Future<bool> reloadEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  Stream<AppUser?> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromDoc(doc);
    });
  }

  Future<void> updateLanguage(String uid, String lang) async {
    await _db.collection('users').doc(uid).update({'language': lang});
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('not_signed_in');
    final uid = user.uid;
    await user.delete();
    try {
      await _db.collection('users').doc(uid).delete();
    } catch (_) {}
  }
}
