import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_tuto/pages/AdminPage.dart';
import 'package:crud_tuto/pages/ChefPage.dart';
import 'package:crud_tuto/pages/home_page.dart';
import 'package:crud_tuto/pages/profil_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to handle user login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in the user using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Fetch the user's role from Firestore to determine access level
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      return userDoc['role']; // Return the user's role (Client/Chef)
    } catch (e) {
      return e.toString(); // Error: return the exception message
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // Start the sign-in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Get authentication details from the request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in with Google credentials
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check user role and redirect
        await checkUserRoleAndRedirect(user, context);
      }

      return user;
    } catch (e) {
      // Handle errors
      print(e.toString());
      return null;
    }
  }

  // Function to check user role and redirect
  Future<void> checkUserRoleAndRedirect(User user, BuildContext context) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('/users')
        .doc(user.uid)
        .get();

    String role = userDoc['role']; // Default to 'user' if role is not set

    if (role == "Chef") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChefPage()),
      );

    } else if (role == "Admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  //add sign up with google
// Add sign up with Google
  Future<User?> signUpWithGoogle(BuildContext context) async {
    try {
      // Start the sign-in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Get authentication details from the request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in with Google credentials
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if the user already exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // If the user does not exist, create a new document with user data
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'firstName': gUser.displayName?.split(' ')?.first ?? '',
            'lastName': gUser.displayName?.split(' ')?.last ?? '',
            'email': gUser.email,
            'role': 'Client',
          });
        }

        // Check user role and redirect
        await checkUserRoleAndRedirect(user, context);
      }

      return user;
    } catch (e) {
      // Handle errors
      print(e.toString());
      return null;
    }
  }
}