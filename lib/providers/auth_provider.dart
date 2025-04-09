import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/firebase_database_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();

  AuthStatus _status = AuthStatus.uninitialized;
  User? _user;
  UserModel? _userModel;
  bool _isAdmin = false;
  String? _error;
  bool _loading = false;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isAdmin => _isAdmin;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Constructor
  AuthProvider() {
    _init();
  }

  // Initialize the provider
  Future<void> _init() async {
    _authService.authStateChanges.listen((User? user) async {
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        _userModel = null;
        _isAdmin = false;
      } else {
        _status = AuthStatus.authenticated;
        _user = user;
        await _loadUserModel();
      }

      notifyListeners();
    });
  }

  // Load user model
  Future<void> _loadUserModel() async {
    if (_user == null) return;

    try {
      _setLoading(true);

      final userModel = await _authService.getUserModel(_user!.uid);
      if (userModel != null) {
        _userModel = userModel;
        _isAdmin = await _databaseService.isUserAdmin(_user!.uid);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signUpWithEmailAndPassword(
        email,
        password,
        displayName,
      );

      return user != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      return user != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signInWithGoogle();

      return user != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signInWithApple();

      return user != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    File? profileImage,
  }) async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _clearError();

      String? photoUrl;

      if (profileImage != null) {
        photoUrl = await _storageService.uploadProfileImage(
          profileImage,
          _user!.uid,
        );
      }

      await _authService.updateUserProfile(
        _user!.uid,
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Reload user model
      await _loadUserModel();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.changePassword(currentPassword, newPassword);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount(String password) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.deleteAccount(password);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
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
