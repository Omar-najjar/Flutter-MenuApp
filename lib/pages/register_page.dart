import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_tuto/components/my_button.dart';
import 'package:crud_tuto/components/my_textfield.dart';
import 'package:crud_tuto/components/square_tile.dart';
import 'package:crud_tuto/pages/home_page.dart';
import 'package:crud_tuto/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController(); // Contrôleur pour le prénom
  final lastNameController = TextEditingController();



  // Méthode pour afficher un message d'erreur ou de succès
  void showMessageDialog(String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isSuccess ? Colors.green[500] : Colors.blue[500],
          title: Text(isSuccess ? 'Succès' : 'Erreur',
              style: const TextStyle(color: Colors.white)),
          content: Text(message, style: const TextStyle(color: Colors.white)),
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

  // Méthode pour inscrire l'utilisateur
  Future<void> signUserUp() async {
    // Affichage du cercle de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Vérification si les mots de passe correspondent
      if (passwordController.text == confirmPasswordController.text) {
        // Création de l'utilisateur
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        // Fermeture du cercle de chargement
        Navigator.pop(context);


        // Stocker le prénom dans Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'email': emailController.text,
          'role': 'Client', // Définir le rôle par défaut à "Client"
        });

        // Fermeture du cercle de chargement
        Navigator.pop(context);

        // Affichage du message de succès
        showMessageDialog("Inscription réussie !", isSuccess: true);

        // Fermeture du cercle de chargement
        Navigator.pop(context);

        // Redirection vers la page de connexion après un court délai pour lire le message
        await Future.delayed(const Duration(seconds: 1));


        widget.onTap?.call(); // Navigue vers la page de connexion
      } else {

        // Fermeture du cercle de chargement
        Navigator.pop(context);

        // Afficher un message d'erreur si les mots de passe ne correspondent pas
        showMessageDialog("Les mots de passe ne correspondent pas !");
      }
    } on FirebaseAuthException catch (e) {

      Navigator.pop(context); // Fermer le cercle de chargement

      if (e.code == 'email-already-in-use') {
        showMessageDialog("Cet e-mail est déjà utilisé.");

      } else if (e.code == 'invalid-email') {
        showMessageDialog("Adresse e-mail invalide.");

      } else if (e.code == 'weak-password') {
        showMessageDialog("Le mot de passe est trop faible.");

      } else {
        showMessageDialog("Une erreur est survenue. Veuillez réessayer.");
      }
    }
  }

  // Connexion avec Google


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                Icon(
                  Icons.lock,
                  size: 100,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 25),
                Text(
                  'Let\'s create an account for you!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),

                // Champ pour le prénom
                MyTextfield(
                  controller: firstNameController,
                  hintText: 'First Name',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                // Champ pour le nom
                MyTextfield(
                  controller: lastNameController,
                  hintText: 'Last Name',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                // Champ pour l'email
                MyTextfield(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                // Champ pour le mot de passe
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                // Champ pour confirmer le mot de passe
                MyTextfield(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 25),
                MyButton(text: "Sign Up", onTap: signUserUp),
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
                          'Or SignUp with Google',
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
                    SquareTile(
                      onTap: () async {
                        User? user = await AuthService().signUpWithGoogle(context);
                        if (user != null) {

                          // Affichage du message de succès
                          showMessageDialog("Inscription réussie !", isSuccess: true);

                          // Fermeture du cercle de chargement
                          Navigator.pop(context);

                          // Redirection vers la page de connexion après un court délai pour lire le message
                          await Future.delayed(const Duration(seconds: 1));


                          widget.onTap?.call(); // Navigue vers la page de connexion

                          /*Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );*/
                        } else {
                          showMessageDialog("Échec de la connexion avec Google");
                        }
                      },
                      ImagePath: 'lib/images/google.png',
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account ',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
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


