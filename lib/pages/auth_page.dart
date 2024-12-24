import 'package:crud_tuto/pages/home_page.dart';
import 'package:crud_tuto/pages/login_or_register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // USER IS LOGGED IN
          if (snapshot.hasData) {
            return const HomePage();
          }

          //USER IS NOT LOGGED IN
          else {
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
