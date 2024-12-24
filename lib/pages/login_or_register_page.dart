import 'package:crud_tuto/pages/login_page.dart';
import 'package:crud_tuto/pages/register_page.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginOrRegisterPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            AuthService authService = AuthService();
            await authService.signInWithGoogle(context);
          },
          child: Text("Sign in with Google"),
        ),
      ),
    );
  }
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  
  // initially show Login page 
  bool showLoginPage = true;

  // toogle between login and register page
void togglePages(){
  setState(() {
   showLoginPage = !showLoginPage;
  });
}
  @override
  Widget build(BuildContext context) {
   if (showLoginPage){
    return LoginPage(
      onTap:togglePages ,
    );
   }else{
    return RegisterPage(
      onTap: togglePages,
    );
   }
  }
}