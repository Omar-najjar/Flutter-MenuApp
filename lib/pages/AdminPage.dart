import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _changeUserRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({'role': newRole});
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('User role updated successfully!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page - Gestion des rôles'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Vous pouvez modifier les rôles des utilisateurs ...',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final users = snapshot.data!.docs.where((user) {
                    final role = user['role'];
                    return role == 'Chef' || role == 'Client';
                  }).toList();
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final userId = user.id;
                      final userName = user['firstName'];
                      final userRole = user['role'];

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: ListTile(
                          title: Text(userName),
                          subtitle: Text('Role: $userRole'),
                          trailing: DropdownButton<String>(
                            value: userRole,
                            items: ['Chef', 'Client'].map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (newRole) {
                              if (newRole != null) {
                                _changeUserRole(userId, newRole);
                              }
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
    );
  }
}