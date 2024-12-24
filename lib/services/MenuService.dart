import 'package:cloud_firestore/cloud_firestore.dart';
import 'Category.dart';
import 'Recette.dart';

class MenuService {
  final CollectionReference menuCollection = FirebaseFirestore.instance.collection('Recettes');
  final CollectionReference categoryCollection = FirebaseFirestore.instance.collection('Categories');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addRecette(Recette item) {
    return menuCollection.add(item.toMap());
  }

  Future<void> updateRecette(Recette item) {
    return menuCollection.doc(item.id).update(item.toMap());
  }

  Future<void> deleteRecette(String id) {
    return menuCollection.doc(id).delete();
  }

  Stream<List<Recette>> getRecettes() {
    return menuCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Recette.fromFirestore(doc)).toList();
    });
  }

  Stream<Recette> getRecetteById(String id) {
    return menuCollection.doc(id).snapshots().map((doc) => Recette.fromFirestore(doc));
  }

  Future<void> addCategory(Category category) {
    return categoryCollection.add(category.toMap());
  }

  Future<void> updateCategory(Category category) {
    return categoryCollection.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) {
    return categoryCollection.doc(id).delete();
  }

  Stream<List<Category>> getCategories() {
    return categoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Category>> getCategoriesCards() {
    return _firestore.collection('Categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Recette>> getRecettesByCategory(String category) {
    return _firestore
        .collection('Recettes')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Recette.fromFirestore(doc)).toList();
    });
  }

  /*Future<void> submitRating(String recetteId, String userId, double rating) async {
    DocumentReference recetteRef = menuCollection.doc(recetteId);
    DocumentSnapshot recetteSnapshot = await recetteRef.get();

    if (recetteSnapshot.exists) {
      Recette recette = Recette.fromFirestore(recetteSnapshot);
      double totalRating = recette.averageRating * recette.numberOfRatings;
      totalRating += rating;
      recette.numberOfRatings += 1;
      recette.averageRating = totalRating / recette.numberOfRatings;

      await recetteRef.update({
        'averageRating': recette.averageRating,
        'numberOfRatings': recette.numberOfRatings,
      });
    }
  }*/

  Future<void> submitRating(String recetteId, String userId, double rating) async {
    DocumentReference recetteRef = menuCollection.doc(recetteId);
    DocumentSnapshot recetteSnapshot = await recetteRef.get();

    if (recetteSnapshot.exists) {
      Recette recette = Recette.fromFirestore(recetteSnapshot);

      // Check if the user has already rated this recipe
      DocumentReference userRatingRef = recetteRef.collection('ratings').doc(userId);
      DocumentSnapshot userRatingSnapshot = await userRatingRef.get();

      if (userRatingSnapshot.exists) {
        // User has already rated this recipe
        throw Exception('You have already rated this recipe.');
      } else {
        // User has not rated this recipe yet
        double totalRating = recette.averageRating * recette.numberOfRatings;
        totalRating += rating;
        recette.numberOfRatings += 1;
        recette.averageRating = totalRating / recette.numberOfRatings;

        await recetteRef.update({
          'averageRating': recette.averageRating,
          'numberOfRatings': recette.numberOfRatings,
        });

        // Save the user's rating
        await userRatingRef.set({'rating': rating});
      }
    }
  }


  Future<void> submitComment(String recetteId, String userId, String comment) async {
    DocumentReference recetteRef = menuCollection.doc(recetteId);
    DocumentSnapshot recetteSnapshot = await recetteRef.get();

    if (recetteSnapshot.exists) {
      Recette recette = Recette.fromFirestore(recetteSnapshot);

      // Check if the user has already commented on this recipe
      DocumentReference userCommentRef = recetteRef.collection('comments').doc(userId);
      DocumentSnapshot userCommentSnapshot = await userCommentRef.get();

      if (userCommentSnapshot.exists) {
        // User has already commented on this recipe
        throw Exception('You have already commented on this recipe.');
      } else {
        // User has not commented on this recipe yet
        recette.comments.add(comment);

        await recetteRef.update({
          'comments': recette.comments,
        });

        // Save the user's comment
        await userCommentRef.set({'comment': comment});
      }
    }
  }

}