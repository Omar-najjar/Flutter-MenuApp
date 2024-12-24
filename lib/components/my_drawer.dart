import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_tuto/components/my_drawer_tile.dart';
import 'package:crud_tuto/pages/AdminPage.dart';
import 'package:crud_tuto/pages/ChefPage.dart';
import 'package:crud_tuto/pages/login_or_register_page.dart';
import 'package:crud_tuto/pages/menu_page.dart';
import 'package:crud_tuto/pages/profil_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../pages/home_page.dart';
import '../pages/search_page.dart';
import '../pages/settings_page.dart';


class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  Future<String?> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userData['role'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // app logo
          Padding(
            padding: const EdgeInsets.only(top:80.0),
            child: Icon(
              Icons.lock_open_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Divider(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
          // home list tile
          MyDrawerTile(
              text: 'H O M E',
              icon: Icons.home,
              onTap: (){
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=>const HomePage(),
                    )
                );
              }
          ),

          MyDrawerTile(
              text: 'S E A R C H ',
              icon: Icons.search,
              onTap: (){
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=>const SearchPage(),
                    )
                );
              }
          ),



          MyDrawerTile(
              text: 'P R O F I L E ',
              icon: Icons.person,
              onTap: (){
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=>const ProfilPage(),
                    )
                );
              }
          ),
          MyDrawerTile(
              text: 'S E T T I N G ',
              icon: Icons.settings,
              onTap: (){
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=>const SettingsPage(),
                )
                );
              }
          ),
          FutureBuilder<String?>(
            future: _getUserRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data == 'Chef'|| snapshot.data == 'Admin') {
                  return MyDrawerTile(
                    text: 'G E R E R  M E N U',
                    icon: Icons.menu,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChefPage(),
                        ),
                      );
                    },
                  );
                }
              }
              return Container(); // Return an empty container if not a Chef
            },
          ),

          FutureBuilder(
            future: _getUserRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data == 'Admin' ) {
                  return MyDrawerTile(
                    text: 'A D M I N',
                    icon: Icons.admin_panel_settings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminPage(),
                        ),
                      );
                    },
                  );
                }
              }
              return Container(); // Return an empty container if not an Admin
            },
          ),

          const Spacer(),

          MyDrawerTile(
            text: 'L O G O U T ',
            icon: Icons.logout,
            onTap: () async {
              // Fermer le drawer avant de faire d'autres actions
              Navigator.pop(context);

              // Déconnecter l'utilisateur de Firebase
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();



              // Rediriger vers la page de connexion
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginOrRegisterPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 25,),

        ],
      ),

    );
  }
}
