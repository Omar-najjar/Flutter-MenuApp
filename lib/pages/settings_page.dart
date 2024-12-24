import 'package:crud_tuto/pages/profil_page.dart';
import 'package:crud_tuto/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/my_drawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar:
    AppBar(title: Text("Settings"),
      backgroundColor: Theme.of(context).colorScheme.surface,
    ),
      drawer: MyDrawer(),
      backgroundColor:  Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(left: 25, top: 10, right: 25),
            padding: const EdgeInsets.all(25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("dark Mode",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:  Theme.of(context).colorScheme.inversePrimary,
                ),
                ),

                // switch
                CupertinoSwitch(value: Provider.of<ThemeProvider>
                  (context,listen:false).isDarkMode,
                    onChanged: (value)=>Provider.of<ThemeProvider>(
                      context, listen: false)
                        .toggleTheme(),
                ),
              ],
            ),
          ),


          GestureDetector(
            onTap: () {
              // Rediriger vers la page de profil
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilPage(), // Remplacez par le nom de votre page de profil
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(left: 25, top: 10, right: 25),
              padding: const EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Modifier le profil",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),

                  // Ajout d'une icône de flèche pour indiquer la navigation
                  Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ],
              ),
            ),
          )

        ],
      ),



    );
  }
}
