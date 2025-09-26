import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_taker/core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notes_taker/models/user_info.dart';

abstract class AuthServices {
  Future<String> login(String email, String password);
  Future<String> register(String email, String password, String name);
  User? currentUser();
  Future<void> logOut();
  Future<String> googleLogin();
  Future<UserData?> getUserData();
  Future<void> updateUserData({required String name, required String imgUrl});
  Future<void> forgetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}

class AuthServicesImpl implements AuthServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String> login(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception();
    }
  }

  @override
  Future<String> register(String email, String password, String name) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      final userData = UserData(
        name: name,
        email: email,
        id: user.uid,
        createdAt: DateTime.now().toIso8601String(),
      );
      await FirestoreServices.createCollectionWithDoc(
        collectionName: 'users',
        docName: user.uid,
        data: userData.toMap(),
      );
      return user.uid;
    } else {
      throw Exception();
    }
  }

  @override
  User? currentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn.instance.signOut();
  }

  @override
  Future<String> googleLogin() async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(
      serverClientId:
          '786625229768-d66dspi2ds7egpvu0620i1cd9ccq3a2k.apps.googleusercontent.com',
    );

    // Sign in with Google
    final gUser = await googleSignIn.authenticate();
    final gAuth = gUser.authentication;

    // Build a Firebase credential and sign in
    final credential = GoogleAuthProvider.credential(idToken: gAuth.idToken);
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) throw Exception('Google sign-in failed');

    // ✅ Grab Google profile info
    final name = user.displayName ?? '';
    final email = user.email ?? '';

    // Check if user doc already exists
    final existing = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!existing.exists) {
      final userData = UserData(
        name: name,
        email: email,
        id: user.uid,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Use your FirestoreServices helper
      await FirestoreServices.createCollectionWithDoc(
        collectionName: 'users',
        docName: user.uid,
        data: userData.toMap(),
      );
    }

    return user.uid;
  }

  @override
  Future<UserData?> getUserData({String? uid}) async {
    // Use provided uid if available, else fallback to current user
    final effectiveUid = uid ?? _firebaseAuth.currentUser?.uid;
    if (effectiveUid == null) return null;

    final doc = await FirestoreServices.getDocData(
      collectionName: 'users',
      docName: effectiveUid,
      fromMap: (data, docId) => UserData.fromMap(data),
    );

    return doc;
  }

  @override
  Future<void> updateUserData({
    required String name,
    String? imgUrl, // now optional
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("No user logged in");

    final updateData = {"name": name};
    if (imgUrl != null) {
      updateData["imgUrl"] = imgUrl;
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update(updateData);
  }

  @override
  Future<void> forgetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
