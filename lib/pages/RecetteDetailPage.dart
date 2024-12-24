import 'package:flutter/material.dart';
import '../services/Category.dart';
import '../services/Recette.dart';
import '../services/MenuService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RecetteDetailPage extends StatefulWidget {
  final Recette recette;

  const RecetteDetailPage({Key? key, required this.recette}) : super(key: key);

  @override
  _RecetteDetailPageState createState() => _RecetteDetailPageState();
}

class _RecetteDetailPageState extends State<RecetteDetailPage> {
  final MenuService _menuService = MenuService();
  final List<String> _categories = ['PLATS', 'SALADES', 'JUS', 'GATEAUX'];
  String? userRole;
  double? userRating;
  String? userComment;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userRole = userDoc['role'];
      });
    }
  }

  Future<void> _submitRating(double rating) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _menuService.submitRating(widget.recette.id, user.uid, rating);
        setState(() {
          userRating = rating;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _submitComment(String comment) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _menuService.submitComment(widget.recette.id, user.uid, comment);
        setState(() {
          userComment = comment;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _showEditRecetteDialog(Recette recette) {
    String name = recette.name;
    String description = recette.description;
    String? selectedCategory = recette.category;

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Category>>(
          future: _menuService.getCategories().first,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final categories = snapshot.data!;
              return AlertDialog(
                title: Text('Edit Recette'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Name'),
                      controller: TextEditingController(text: name),
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Description'),
                      controller: TextEditingController(text: description),
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Category'),
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.name,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
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
                      if (selectedCategory != null) {
                        _menuService.updateRecette(Recette(
                          id: recette.id,
                          name: name,
                          description: description,
                          category: selectedCategory!,
                          imagePath: recette.imagePath,
                        ));
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Save'),
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
    return StreamBuilder<Recette>(
      stream: _menuService.getRecetteById(widget.recette.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final recette = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(recette.name),
              actions: [
                if (userRole == 'Chef' || userRole == 'Admin')
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditRecetteDialog(recette);
                    },
                  ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Image.asset(recette.imagePath, height: 250, width: double.infinity, fit: BoxFit.cover),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              recette.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Category : ${recette.category}',
                      style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description :',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recette.description,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    if (userRole == 'Client')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rate this Recette:',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          RatingBar.builder(
                            initialRating: userRating ?? 0,
                            minRating: 0,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              _submitRating(rating);
                            },
                          ),


                          const SizedBox(height: 20),
                          Text(
                            'Add a Comment:',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Comment',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              userComment = value;
                            },
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.black),
                            ),
                            onPressed: () {
                              if (userComment != null && userComment!.isNotEmpty) {
                                _submitComment(userComment!);
                              }
                            },
                            child: Text('Submit'),
                          ),
                        ],
                      ),


                    const SizedBox(height: 24),
                    Text(
                      'Average Rating: ${recette.averageRating.toStringAsFixed(1)} (${recette.numberOfRatings} ratings)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold , color: Colors.blueAccent),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Comments:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold ,color: Colors.indigo),
                    ),
                    ...recette.comments.map((comment) => Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(comment),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}