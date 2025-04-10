import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/proverb.dart';
import '../models/category.dart';

class FirebaseDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Collection references
  CollectionReference get _proverbsCollection =>
      _firestore.collection('proverbs');
  CollectionReference get _categoriesCollection =>
      _firestore.collection('categories');
  CollectionReference get _usersCollection => _firestore.collection('users');

  // ************ Proverbs Methods ************

  // Get all proverbs
  // Stream<List<Proverb>> getProverbs({String? categoryId}) {
  //   Query query = _proverbsCollection.where('isActive', isEqualTo: true);

  //   if (categoryId != null) {
  //     query = query.where('categoryId', isEqualTo: categoryId);
  //   }

  //   return query.orderBy('createdAt', descending: true).snapshots().map((
  //     snapshot,
  //   ) {
  //     return snapshot.docs.map((doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       return Proverb.fromJson(data);
  //     }).toList();
  //   });
  // }
  Future<List<Proverb>> getAllProverbs() async {
    try {
      // Just get all documents without filters or ordering
      final snapshot = await _proverbsCollection.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Proverb.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching proverbs: $e');
      return [];
    }
  }

  // Replace the streaming method with this simple one
  Stream<List<Proverb>> getProverbs({String? categoryId}) {
    // Create a stream controller to manage the data
    final controller = StreamController<List<Proverb>>();

    // Load all proverbs once and filter them
    getAllProverbs()
        .then((allProverbs) {
          // Filter the list in memory
          final filteredProverbs =
              allProverbs.where((proverb) {
                if (!proverb.isActive) return false;

                if (categoryId != null && categoryId.isNotEmpty) {
                  return proverb.categoryId == categoryId;
                }

                return true;
              }).toList();

          // Add to stream and close
          controller.add(filteredProverbs);
          controller.close();
        })
        .catchError((error) {
          controller.addError(error);
          controller.close();
        });

    return controller.stream;
  }

  // Get proverb by id
  Future<Proverb?> getProverbById(String id) async {
    try {
      final docSnapshot = await _proverbsCollection.doc(id).get();

      if (docSnapshot.exists) {
        return Proverb.fromJson(docSnapshot.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Add proverb
  Future<String> addProverb({
    required String text,
    required String author,
    required String categoryId,
    required String backgroundImageUrl,
  }) async {
    try {
      final id = _uuid.v4();

      final proverb = Proverb(
        id: id,
        text: text,
        author: author,
        categoryId: categoryId,
        backgroundImageUrl: backgroundImageUrl,
        createdAt: DateTime.now(),
      );

      await _proverbsCollection.doc(id).set(proverb.toJson());

      return id;
    } catch (e) {
      rethrow;
    }
  }

  // Update proverb
  Future<void> updateProverb({
    required String id,
    String? text,
    String? author,
    String? categoryId,
    String? backgroundImageUrl,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (text != null) updates['text'] = text;
      if (author != null) updates['author'] = author;
      if (categoryId != null) updates['categoryId'] = categoryId;
      if (backgroundImageUrl != null) {
        updates['backgroundImageUrl'] = backgroundImageUrl;
      }
      if (isActive != null) updates['isActive'] = isActive;

      if (updates.isNotEmpty) {
        await _proverbsCollection.doc(id).update(updates);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete proverb
  Future<void> deleteProverb(String id) async {
    try {
      await _proverbsCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Increment proverb view count
  Future<void> incrementProverbViewCount(String id) async {
    try {
      await _proverbsCollection.doc(id).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ************ Categories Methods ************

  // Get all categories
  Stream<List<Category>> getCategories({bool activeOnly = true}) {
    Query query = _categoriesCollection;

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category.fromJson(data);
      }).toList();
    });
  }

  // Add category
  Future<String> addCategory({
    required String name,
    String? description,
    String? iconUrl,
    int order = 0,
  }) async {
    try {
      final id = _uuid.v4();

      final category = Category(
        id: id,
        name: name,
        description: description,
        iconUrl: iconUrl,
        order: order,
      );

      await _categoriesCollection.doc(id).set(category.toJson());

      return id;
    } catch (e) {
      rethrow;
    }
  }

  // Update category
  Future<void> updateCategory({
    required String id,
    String? name,
    String? description,
    String? iconUrl,
    int? order,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (iconUrl != null) updates['iconUrl'] = iconUrl;
      if (order != null) updates['order'] = order;
      if (isActive != null) updates['isActive'] = isActive;

      if (updates.isNotEmpty) {
        await _categoriesCollection.doc(id).update(updates);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete category
  Future<void> deleteCategory(String id) async {
    try {
      // Check if category has proverbs
      final proverbsQuery =
          await _proverbsCollection
              .where('categoryId', isEqualTo: id)
              .limit(1)
              .get();

      if (proverbsQuery.docs.isNotEmpty) {
        throw Exception(
          'Cannot delete category because it has proverbs. Deactivate it instead.',
        );
      }

      await _categoriesCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ************ User Preferences Methods ************

  // Toggle favorite proverb
  Future<void> toggleFavoriteProverb(String userId, String proverbId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found.');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final List<String> favorites = List<String>.from(
        userData['favoriteProverbs'] ?? [],
      );

      if (favorites.contains(proverbId)) {
        // Remove from favorites
        favorites.remove(proverbId);
      } else {
        // Add to favorites
        favorites.add(proverbId);
      }

      await _usersCollection.doc(userId).update({
        'favoriteProverbs': favorites,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Toggle bookmark proverb
  Future<void> toggleBookmarkProverb(String userId, String proverbId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found.');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final List<String> bookmarks = List<String>.from(
        userData['bookmarkedProverbs'] ?? [],
      );

      if (bookmarks.contains(proverbId)) {
        // Remove from bookmarks
        bookmarks.remove(proverbId);
      } else {
        // Add to bookmarks
        bookmarks.add(proverbId);
      }

      await _usersCollection.doc(userId).update({
        'bookmarkedProverbs': bookmarks,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Mark proverb as read
  Future<void> markProverbAsRead(String userId, String proverbId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found.');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final List<String> readProverbs = List<String>.from(
        userData['readProverbs'] ?? [],
      );

      if (!readProverbs.contains(proverbId)) {
        readProverbs.add(proverbId);

        await _usersCollection.doc(userId).update({
          'readProverbs': readProverbs,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get user favorite proverbs
  Future<List<Proverb>> getUserFavoriteProverbs(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found.');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final List<String> favoriteIds = List<String>.from(
        userData['favoriteProverbs'] ?? [],
      );

      if (favoriteIds.isEmpty) {
        return [];
      }

      // Firestore doesn't support large 'in' queries, so we need to chunk
      const chunkSize = 10;
      final List<Proverb> results = [];

      for (var i = 0; i < favoriteIds.length; i += chunkSize) {
        final end =
            (i + chunkSize < favoriteIds.length)
                ? i + chunkSize
                : favoriteIds.length;
        final chunk = favoriteIds.sublist(i, end);

        final querySnapshot =
            await _proverbsCollection
                .where('id', whereIn: chunk)
                .where('isActive', isEqualTo: true)
                .get();

        final proverbs =
            querySnapshot.docs
                .map(
                  (doc) => Proverb.fromJson(doc.data() as Map<String, dynamic>),
                )
                .toList();

        results.addAll(proverbs);
      }

      return results;
    } catch (e) {
      rethrow;
    }
  }

  // Get user bookmarked proverbs
  Future<List<Proverb>> getUserBookmarkedProverbs(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found.');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final List<String> bookmarkedIds = List<String>.from(
        userData['bookmarkedProverbs'] ?? [],
      );

      if (bookmarkedIds.isEmpty) {
        return [];
      }

      // Firestore doesn't support large 'in' queries, so we need to chunk
      const chunkSize = 10;
      final List<Proverb> results = [];

      for (var i = 0; i < bookmarkedIds.length; i += chunkSize) {
        final end =
            (i + chunkSize < bookmarkedIds.length)
                ? i + chunkSize
                : bookmarkedIds.length;
        final chunk = bookmarkedIds.sublist(i, end);

        final querySnapshot =
            await _proverbsCollection
                .where('id', whereIn: chunk)
                .where('isActive', isEqualTo: true)
                .get();

        final proverbs =
            querySnapshot.docs
                .map(
                  (doc) => Proverb.fromJson(doc.data() as Map<String, dynamic>),
                )
                .toList();

        results.addAll(proverbs);
      }

      return results;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is admin
  Future<bool> isUserAdmin(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) {
        return false;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['isAdmin'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
}
