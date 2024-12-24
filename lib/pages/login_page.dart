import 'package:crud_tuto/components/my_button.dart';
import 'package:crud_tuto/components/my_textfield.dart';
import 'package:crud_tuto/components/square_tile.dart';
import 'package:crud_tuto/pages/AdminPage.dart';
import 'package:crud_tuto/pages/ChefPage.dart';
import 'package:crud_tuto/pages/home_page.dart';
import 'package:crud_tuto/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final AuthService _authService = AuthService(); // Instance of AuthService


  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;

  // Méthode pour afficher un message d'erreur
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue[500],
          title: const Text('Erreur', style: TextStyle(color: Colors.white)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Méthode de connexion de l'utilisateur
  Future<void> signUserIn() async {

    // Affichage du cercle de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Tentative de connexion
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pop(context);


      String? result = await _authService.login(
        email: emailController.text,
        password: passwordController.text,
      );
      // Fermer le cercle de chargement après connexion réussie
      // Navigate based on role or show error message
      if (result == 'Chef') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ChefPage(),
          ),
        );
      } else if (result == 'Client') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );
      } else if (result == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login Failed: $result'), // Show error message
        ));
      }




    } on FirebaseAuthException catch (e) {
      // Fermer le cercle de chargement si une erreur survient
      Navigator.pop(context);

      // Afficher le message d'erreur en fonction du code d'erreur
      if (e.code == 'user-not-found') {
        showErrorDialog('Incorrect Email: The email you entered is not registered.');
      } else if (e.code == 'wrong-password') {
        showErrorDialog('Incorrect Password: The password you entered is incorrect.');
      } else {
        showErrorDialog('Identifiant ou mot de passe invalide !');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Icon(
                  Icons.lock_open_rounded,
                  size: 100,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 50),
                Text(
                  'Welcome back, you\'ve been missed!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextfield(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forget Password?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(
                  text: "Sign In",
                  onTap: signUserIn,
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bouton Google Sign-In
                    SquareTile(
                      onTap: () async {
                        // Essayer de se connecter avec Google
                        User? user = await AuthService().signInWithGoogle(context);

                        if (user != null) {
                          // Check user role and redirect
                          await AuthService().checkUserRoleAndRedirect(user, context);
                        } else {
                          // Afficher un message d'erreur si la connexion échoue ou est annulée
                          showErrorDialog("Google sign-in failed or was canceled.");
                        }
                      },
                      ImagePath: 'lib/images/google.png',
                    ),
                    const SizedBox(width: 25),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}