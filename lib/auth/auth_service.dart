import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // _firestore.collection("Users").doc(userCredential.user!.uid).set({
      //   'uid': userCredential.user!.uid,
      //   'email': email,
      // });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign up

  Future<UserCredential> signUpWithEmailPassword(
      String email, password, username) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
        'pf_path':
            "https://firebasestorage.googleapis.com/v0/b/app-chat-97ecb.appspot.com/o/Profiles%2Fprofile_image.jpg?alt=media&token=6ffca4f1-2e1c-4d5c-950b-0e1bd7b2076c",
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw e; // Optionally rethrow the exception if you need to handle it elsewhere
    }
  }

  String getCurrentUserID() {
    return _auth.currentUser!.uid;
  }

  String getCurrentUserEmail() {
    return _auth.currentUser!.email!;
  }

  // get current user name
  Future<String> getCurrentUserName() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot userDoc =
          await _firestore.collection("Users").doc(uid).get();
      return userDoc['username'];
    } catch (e) {
      throw Exception('Error fetching username: $e');
    }
  }

  //get receiver user name
  Future<String> getReceiverUsername(String receiverId) async {
    try {
      String uid = receiverId;
      DocumentSnapshot userDoc =
          await _firestore.collection("Users").doc(uid).get();
      return userDoc['username'];
    } catch (e) {
      throw Exception('Error fetching username: $e');
    }
  }

  // errors
}
