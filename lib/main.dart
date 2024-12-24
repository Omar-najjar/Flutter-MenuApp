import 'package:crud_tuto/firebase_options.dart';
import 'package:crud_tuto/pages/ChefPage.dart';
import 'package:crud_tuto/pages/auth_page.dart';
import 'package:crud_tuto/pages/home_page.dart';
import 'package:crud_tuto/pages/login_or_register_page.dart';
import 'package:crud_tuto/pages/menu_page.dart';
import 'package:crud_tuto/themes/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // User is logged in, check their role
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.done) {
                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      String role = userSnapshot.data!['role'];
                      if (role == 'Chef') {
                        return const ChefPage();
                      } else {
                        return const HomePage();
                      }
                    } else {
                      return const LoginOrRegisterPage();
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            } else {
              return const LoginOrRegisterPage();
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}