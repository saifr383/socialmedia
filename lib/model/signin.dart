import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

class google with ChangeNotifier {
  user Currentuser=user(email: '',profilename: '',description: '',imageurl: '');
  var _gsign = false;
  GoogleSignInAccount? _user;
  Future signingoogle() async {
    final guser = await GoogleSignIn().signIn();
    if (guser == null) return;
    _gsign = true;
    _user = guser;
    final auth = await guser.authentication;
    final cred = GoogleAuthProvider.credential(
        idToken: auth.idToken, accessToken: auth.accessToken);
    await FirebaseAuth.instance.signInWithCredential(cred);
    var check = FirebaseAuth.instance.currentUser;
    DocumentSnapshot s = await FirebaseFirestore.instance
        .collection('users')
        .doc(check!.email)
        .get();
    if (!s.exists)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(check.email)
          .set({
        'email': check.email,
        'profilename': check.displayName,
        'image': check.photoURL,
        'description': check.tenantId
      });
    Currentuser=user(email: check.email,profilename:
    check.displayName,imageurl: check.photoURL,description: check.tenantId);
    notifyListeners();
  }

  Future<void> signout() async {
    if (_gsign) await GoogleSignIn().disconnect();
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  Future<void> siginemail(String email, String pass) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();
      Currentuser = user(
          email: snapshot['email'],
          profilename: snapshot['profilename'],
          imageurl: snapshot['image'],
          description: snapshot['description']);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
          msg: e.code,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> sigup(String email, String pass, user newuser) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
      await FirebaseAuth.instance.signOut();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newuser.email)
          .set({
        'email': newuser.email,
        'profilename': newuser.profilename,
        'image': newuser.imageurl,
        'description': newuser.description
      });
      Fluttertoast.showToast(
          msg: 'SignUp Sucessfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
          msg: e.code,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
