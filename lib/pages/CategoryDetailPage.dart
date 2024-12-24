import 'package:flutter/material.dart';
import '../services/Category.dart';
import '../services/MenuService.dart';
import '../services/Recette.dart';
import 'RecetteDetailPage.dart';

class CategoryDetailPage extends StatefulWidget {
  final Category category;

  CategoryDetailPage({required this.category});

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final MenuService _menuService = MenuService();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Vous trouverez les recettes de catégorie ${widget.category.name} ...',
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
                labelText: 'Rechercher une recette',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Recette>>(
              stream: _menuService.getRecettesByCategory(widget.category.name),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final recettes = snapshot.data!
                      .where((recette) => recette.name.toLowerCase().contains(searchQuery))
                      .toList();
                  if (recettes.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucune recette disponible pour cette catégorie.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: recettes.length,
                    itemBuilder: (context, index) {
                      final item = recettes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        color: Theme.of(context).colorScheme.secondary,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              item.imagePath,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            item.name.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                          subtitle: Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecetteDetailPage(recette: item),
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