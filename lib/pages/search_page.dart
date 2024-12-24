import 'package:flutter/material.dart';

import '../components/my_drawer.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text("Search"),
    backgroundColor: Theme.of(context).colorScheme.surface,

    actions: [
    IconButton(
    icon: const Icon(Icons.search),
    onPressed: () {
    // Logique de recherche
    },
    ),
    ],
    ),
      drawer: MyDrawer(),
    );
  }
}
