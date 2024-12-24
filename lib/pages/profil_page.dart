import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/text_box.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  // User Firebase instance
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Variables to store first name and last name
  String firstname = "";
  String lastname = "";
  String role = "";

  @override
  void initState() {
    super.initState();
    // Load user data from Firestore on page initialization
    loadUserData();
  }

  // Function to retrieve first name and last name from Firestore
  Future<void> loadUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      setState(() {
        firstname = userDoc['firstName'] ?? "";
        lastname = userDoc['lastName'] ?? "";
        role = userDoc['role'] ?? "user"; // Default to 'user' if role is not set

      });
    } catch (e) {
      print("Error retrieving user data: $e");
    }
  }

  // Function to update a field
  Future<void> editField(String field, String newValue) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({field: newValue});
    setState(() {
      if (field == 'firstName') {
        firstname = newValue;
      } else if (field == 'lastName') {
        lastname = newValue;
      } else if (field == 'role') {
        role = newValue;
      }


    });
  }

  // Function to show an edit dialog
  void showEditDialog(String field, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter new $field"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              String newValue = controller.text;
              if (newValue.isNotEmpty) {
                editField(field, newValue);
              }
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50),
          const Icon(Icons.person, size: 72),
          const SizedBox(height: 10),
          // User email
          Text(
            currentUser.email!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  role,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'My Information',
              style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
          // Display first name and last name from Firestore
          MyTextBox(
            text: firstname,
            sectionName: 'First Name',
            onPressed: () => showEditDialog('firstName', firstname),
          ),
          MyTextBox(
            text: lastname,
            sectionName: 'Last Name',
            onPressed: () => showEditDialog('lastName', lastname),
          ),
        /*  MyTextBox(
            text: role,
            sectionName: 'Role',
            onPressed: () => showEditDialog('role', role),
          ),*/
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}