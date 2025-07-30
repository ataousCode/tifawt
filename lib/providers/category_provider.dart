import 'dart:io';
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/firebase_database_service.dart';
import '../services/firebase_storage_service.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  final FirebaseStorageService _storageService = FirebaseStorageService();

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _loading = false;
  String? _error;

  // Getters
  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  bool get loading => _loading;
  String? get error => _error;

  // Constructor
  CategoryProvider() {
    loadCategories();
  }

  // Load categories
  void loadCategories({bool activeOnly = true}) {
    try {
      _setLoading(true);

      _databaseService.getCategories(activeOnly: activeOnly).listen((
        categories,
      ) async {
        // Filter out categories with no proverbs
        List<Category> categoriesWithProverbs = [];
        
        for (Category category in categories) {
          final proverbCount = await _databaseService.getProverbCountForCategory(category.id);
          if (proverbCount > 0) {
            categoriesWithProverbs.add(category);
          }
        }
        
        _categories = categoriesWithProverbs;

        if (_categories.isNotEmpty && _selectedCategory == null) {
          _selectedCategory = _categories.first;
        }

        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Add category
  Future<bool> addCategory({
    required String name,
    String? description,
    File? iconImage,
    int order = 0,
  }) async {
    try {
      _setLoading(true);

      String? iconUrl;

      if (iconImage != null) {
        iconUrl = await _storageService.uploadCategoryIcon(iconImage);
      }

      await _databaseService.addCategory(
        name: name,
        description: description,
        iconUrl: iconUrl,
        order: order,
      );

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update category
  Future<bool> updateCategory({
    required String id,
    String? name,
    String? description,
    File? iconImage,
    int? order,
    bool? isActive,
  }) async {
    try {
      _setLoading(true);

      String? iconUrl;

      if (iconImage != null) {
        // Get the existing category to delete the old icon
        final existingCategory = _categories.firstWhere((c) => c.id == id);

        if (existingCategory.iconUrl != null) {
          // Delete the old icon
          await _storageService.deleteImageByUrl(existingCategory.iconUrl!);
        }

        // Upload the new icon
        iconUrl = await _storageService.uploadCategoryIcon(iconImage);
      }

      await _databaseService.updateCategory(
        id: id,
        name: name,
        description: description,
        iconUrl: iconUrl,
        order: order,
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

  // Delete category
  Future<bool> deleteCategory(String id) async {
    try {
      _setLoading(true);

      // Get the existing category to delete the icon
      final existingCategory = _categories.firstWhere((c) => c.id == id);

      if (existingCategory.iconUrl != null) {
        // Delete the icon
        await _storageService.deleteImageByUrl(existingCategory.iconUrl!);
      }

      await _databaseService.deleteCategory(id);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Select category
  void selectCategory(String id) {
    final category = _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => _categories.first,
    );

    _selectedCategory = category;
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
  // void _clearError() {
  //   _error = null;
  //   notifyListeners();
  // }
}
