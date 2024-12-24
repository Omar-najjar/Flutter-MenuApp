import 'package:cloud_firestore/cloud_firestore.dart';

class Recette {
  String id;
  String name;
  String description;
  String category;
  String imagePath;
  double averageRating;
  int numberOfRatings;
  List<String> comments;

  Recette({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imagePath,
    this.averageRating = 0.0,
    this.numberOfRatings = 0,
    this.comments = const [],
  });

  factory Recette.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Recette(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imagePath: data['imagePath'] ?? 'lib/images/plats.jpg',
      averageRating: data['averageRating']?.toDouble() ?? 0.0,
      numberOfRatings: data['numberOfRatings'] ?? 0,
      comments: List<String>.from(data['comments'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'imagePath': imagePath,
      'averageRating': averageRating,
      'numberOfRatings': numberOfRatings,
      'comments': comments,
    };
  }
}