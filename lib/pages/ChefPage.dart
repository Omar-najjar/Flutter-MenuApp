import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/my_drawer.dart';
import '../services/Category.dart';
import '../services/MenuService.dart';
import '../services/Recette.dart';
import 'RecetteDetailPage.dart';

class ChefPage extends StatefulWidget {
  const ChefPage({super.key});

  @override
  State<ChefPage> createState() => _ChefPageState();
}

class _ChefPageState extends State<ChefPage> with SingleTickerProviderStateMixin {
  String? userFirstName;
  final MenuService _menuService = MenuService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _getUserFirstName();
    _tabController = TabController(length: 2, vsync: this);
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


//Categorie CRUD
  void _showAddCategoryDialog() {
    String newCategory = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Category Name'),
            onChanged: (value) {
              newCategory = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newCategory.isNotEmpty) {
                  _menuService.addCategory(Category(id: '', name: newCategory));
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(Category category) {
    String updatedCategory = category.name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Category Name'),
            controller: TextEditingController(text: updatedCategory),
            onChanged: (value) {
              updatedCategory = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (updatedCategory.isNotEmpty) {
                  _menuService.updateCategory(Category(id: category.id, name: updatedCategory));
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _menuService.deleteCategory(category.id);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  //Recette CRUD

  void _showAddRecetteDialog() {
    String name = '';
    String description = '';
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Category>>(
          future: _menuService.getCategories().first,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final categories = snapshot.data!;
              return AlertDialog(
                title: Text('Add Recette'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Name'),
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Description'),
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Category'),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.name,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedCategory = value;
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (name.isNotEmpty && description.isNotEmpty && selectedCategory != null) {
                        _menuService.addRecette(Recette(
                          id: '',
                          name: name,
                          description: description,
                          category: selectedCategory!,
                          imagePath: 'lib/images/plats.jpg',
                          //lib/images/salades.jpg
                          //lib/images/gateau.jpg
                          //lib/images/jus.jpg
                        ));
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenue Chef ${userFirstName ?? ''}"),
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Recettes'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      drawer: MyDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Recettes Tab
          Column(
            children: [
              ElevatedButton(
                onPressed: _showAddRecetteDialog,
                child: Text('Add New Recette'),
              ),
              Expanded(
                child: StreamBuilder<List<Recette>>(
                  stream: _menuService.getRecettes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final recettes = snapshot.data!;
                      return ListView.builder(
                        itemCount: recettes.length,
                        itemBuilder: (context, index) {
                          final item = recettes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            color: Theme.of(context).colorScheme.secondary,
                            child: ListTile(
                              leading: Image.asset(
                                item.imagePath,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                item.name,
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
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _menuService.deleteRecette(item.id);
                                },
                              ),
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
          // Categories Tab
          Column(
            children: [
              ElevatedButton(
                onPressed: _showAddCategoryDialog,
                child: Text('Add Category'),
              ),
              Expanded(
                child: StreamBuilder<List<Category>>(
                  stream: _menuService.getCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final categories = snapshot.data!;
                      return ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return ListTile(
                            title: Text(category.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditCategoryDialog(category);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteCategoryDialog(category);
                                  },
                                ),
                              ],
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
        ],
      ),
    );
  }
}