// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/proverb.dart';
import '../services/firebase_database_service.dart';
import '../services/firebase_storage_service.dart';

class ProverbProvider with ChangeNotifier {
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  final FirebaseStorageService _storageService = FirebaseStorageService();

  List<Proverb> _proverbs = [];
  List<Proverb> _favoriteProverbs = [];
  List<Proverb> _bookmarkedProverbs = [];
  String? _selectedCategoryId;
  Proverb? _currentProverb;
  int _currentIndex = 0;
  bool _loading = false;
  String? _error;

  // Getters
  List<Proverb> get proverbs => _proverbs;
  List<Proverb> get favoriteProverbs => _favoriteProverbs;
  List<Proverb> get bookmarkedProverbs => _bookmarkedProverbs;
  String? get selectedCategoryId => _selectedCategoryId;
  Proverb? get currentProverb => _currentProverb;
  int get currentIndex => _currentIndex;
  bool get loading => _loading;
  String? get error => _error;

  // Load proverbs for category
  Future<void> loadProverbsByCategory(String? categoryId) async {
    _selectedCategoryId = categoryId;

    try {
      _setLoading(true);
      _clearError(); // Add this line to clear any previous errors

      _databaseService.getProverbs(categoryId: categoryId).listen((proverbs) {
        _proverbs = proverbs;

        if (_proverbs.isNotEmpty) {
          _currentProverb = _proverbs.first;
          _currentIndex = 0;
        } else {
          _currentProverb = null;
          _currentIndex = 0;
        }

        notifyListeners();
      });
    } catch (e) {
      print("Error loading proverbs: ${e.toString()}");
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  // Future<void> loadProverbsByCategory(String? categoryId) async {
  //   _selectedCategoryId = categoryId;

  //   try {
  //     _setLoading(true);

  //     _databaseService.getProverbs(categoryId: categoryId).listen((proverbs) {
  //       _proverbs = proverbs;

  //       if (_proverbs.isNotEmpty) {
  //         _currentProverb = _proverbs.first;
  //         _currentIndex = 0;
  //       } else {
  //         _currentProverb = null;
  //         _currentIndex = 0;
  //       }

  //       notifyListeners();
  //     });
  //   } catch (e) {
  //     _setError(e.toString());
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Get proverb by id
  Future<Proverb?> getProverbById(String id) async {
    try {
      _setLoading(true);

      return await _databaseService.getProverbById(id);
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Add proverb
  Future<bool> addProverb({
    required String text,
    required String author,
    required String categoryId,
    required File backgroundImage,
  }) async {
    try {
      _setLoading(true);

      // Upload image
      final backgroundImageUrl = await _storageService.uploadProverbImage(
        backgroundImage,
      );

      // Add proverb
      await _databaseService.addProverb(
        text: text,
        author: author,
        categoryId: categoryId,
        backgroundImageUrl: backgroundImageUrl,
      );

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update proverb
  Future<bool> updateProverb({
    required String id,
    String? text,
    String? author,
    String? categoryId,
    File? backgroundImage,
    bool? isActive,
  }) async {
    try {
      _setLoading(true);

      String? backgroundImageUrl;

      if (backgroundImage != null) {
        // Get the existing proverb to delete the old image
        final existingProverb = await _databaseService.getProverbById(id);

        if (existingProverb != null) {
          // Delete the old image
          await _storageService.deleteImageByUrl(
            existingProverb.backgroundImageUrl,
          );
        }

        // Upload the new image
        backgroundImageUrl = await _storageService.uploadProverbImage(
          backgroundImage,
        );
      }

      // Update proverb
      await _databaseService.updateProverb(
        id: id,
        text: text,
        author: author,
        categoryId: categoryId,
        backgroundImageUrl: backgroundImageUrl,
        isActive: isActive,
      );

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete proverb
  Future<bool> deleteProverb(String id) async {
    try {
      _setLoading(true);

      // Get the existing proverb to delete the image
      final existingProverb = await _databaseService.getProverbById(id);

      if (existingProverb != null) {
        // Delete the image
        await _storageService.deleteImageByUrl(
          existingProverb.backgroundImageUrl,
        );
      }

      // Delete proverb
      await _databaseService.deleteProverb(id);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle favorite proverb
  Future<bool> toggleFavoriteProverb(String userId, String proverbId) async {
    try {
      await _databaseService.toggleFavoriteProverb(userId, proverbId);

      // Update favorites list
      await loadFavoriteProverbs(userId);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Toggle bookmark proverb
  Future<bool> toggleBookmarkProverb(String userId, String proverbId) async {
    try {
      await _databaseService.toggleBookmarkProverb(userId, proverbId);

      // Update bookmarks list
      await loadBookmarkedProverbs(userId);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Mark proverb as read
  Future<bool> markProverbAsRead(String userId, String proverbId) async {
    try {
      await _databaseService.markProverbAsRead(userId, proverbId);

      // Increment view count
      await _databaseService.incrementProverbViewCount(proverbId);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Load favorite proverbs
  Future<void> loadFavoriteProverbs(String userId) async {
    try {
      _setLoading(true);

      _favoriteProverbs = await _databaseService.getUserFavoriteProverbs(
        userId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load bookmarked proverbs
  Future<void> loadBookmarkedProverbs(String userId) async {
    try {
      _setLoading(true);

      _bookmarkedProverbs = await _databaseService.getUserBookmarkedProverbs(
        userId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Check if proverb is favorite
  bool isProverbFavorite(String proverbId) {
    return _favoriteProverbs.any((proverb) => proverb.id == proverbId);
  }

  // Check if proverb is bookmarked
  bool isProverbBookmarked(String proverbId) {
    return _bookmarkedProverbs.any((proverb) => proverb.id == proverbId);
  }

  // Go to next proverb
  void nextProverb() {
    if (_proverbs.isEmpty) return;

    _currentIndex = (_currentIndex + 1) % _proverbs.length;
    _currentProverb = _proverbs[_currentIndex];

    notifyListeners();
  }

  // Go to previous proverb
  void previousProverb() {
    if (_proverbs.isEmpty) return;

    _currentIndex = (_currentIndex - 1 + _proverbs.length) % _proverbs.length;
    _currentProverb = _proverbs[_currentIndex];

    notifyListeners();
  }

  // Go to specific proverb by index
  void goToProverbByIndex(int index) {
    if (_proverbs.isEmpty || index < 0 || index >= _proverbs.length) return;

    _currentIndex = index;
    _currentProverb = _proverbs[_currentIndex];

    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
