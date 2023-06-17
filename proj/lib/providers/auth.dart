import 'dart:async';

import 'package:brain_box/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
late final bool isAdmin;

Future<UserCredential> signInAnonymously() async {
  isAdmin = false;
  return _auth.signInAnonymously();
}

Future<UserCredential> signInWithEmailAndPassword(
    String email, String password) async {
  UserCredential userCredential = await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  CurrUser user = await UserProvider.getUserData(userCredential.user?.uid ?? "", FirebaseDatabase.instance);
  isAdmin = user.isAdmin;
  return userCredential;

  /* para incluir email verification:
      User user = result.user;
    // Check if email is verified
    if (!user.emailVerified) {
      throw FirebaseAuthException(
          code: 'user-not-verified',
          message: 'Your email has not been verified. Please check your inbox to verify your email.');
    }
    return result;
   */
}

Future<void> signUpWithEmailAndPassword(
    String email, String password, String username) async {
  await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password);
  String uid = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseDatabase.instance.ref().child('users').child(uid).set({
    'username': username,
    'email': email,
    'phone': '',
    'bio': '',
    'isAdmin': false
  });
}

Future<void> signOut() async {
  return _auth.signOut();
}

