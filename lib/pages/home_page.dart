import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/my_drawer.dart';
import '../services/Category.dart';
import '../services/MenuService.dart';
import 'CategoryDetailPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MenuService _menuService = MenuService();
  String? userFirstName;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _getUserFirstName();
  }

  Future<void> _getUserFirstName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userFirstName = userData['firstName'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenue ${userFirstName ?? ''}"),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Vous trouverez les recettes par catégories ...',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher une catégorie',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          SizedBox(height: 30),
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: _menuService.getCategories(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final categories = snapshot.data!
                      .where((category) => category.name.toLowerCase().contains(searchQuery))
                      .toList();
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        color: Theme.of(context).colorScheme.secondary,
                        child: ListTile(
                          leading: Image.asset(
                            'lib/images/plats.jpg', // Adjust image path as needed
                            width: 200,
                            height: 250,
                            //fit: BoxFit.cover,
                          ),
                          title: Text(
                            category.name.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Vous trouverez tous les recettes de ${category.name.toLowerCase()} içi !',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryDetailPage(category: category),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}