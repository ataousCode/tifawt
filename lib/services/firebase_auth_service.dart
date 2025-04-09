// ignore_for_file: unreachable_switch_default

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;

import '../models/user.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!, displayName);
      }

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      // Create user document if it doesn't exist
      if (userCredential.user != null &&
          userCredential.additionalUserInfo!.isNewUser) {
        await _createUserDocument(
          userCredential.user!,
          userCredential.user!.displayName ?? 'User',
        );
      }

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Apple
  Future<User?> signInWithApple() async {
    if (!Platform.isIOS) {
      throw Exception('Apple Sign In is only available on iOS devices.');
    }

    try {
      final AuthorizationResult result = await TheAppleSignIn.performRequests([
        const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName]),
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          final AppleIdCredential appleIdCredential = result.credential!;

          final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
          final AuthCredential credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken!),
            accessToken: String.fromCharCodes(
              appleIdCredential.authorizationCode!,
            ),
          );

          final UserCredential userCredential = await _firebaseAuth
              .signInWithCredential(credential);

          // Create user document if it doesn't exist
          if (userCredential.user != null &&
              userCredential.additionalUserInfo!.isNewUser) {
            final String displayName = [
              appleIdCredential.fullName?.givenName,
              appleIdCredential.fullName?.familyName,
            ].where((name) => name != null).join(' ');

            await _createUserDocument(
              userCredential.user!,
              displayName.isNotEmpty ? displayName : 'Apple User',
            );
          }

          return userCredential.user;
        case AuthorizationStatus.cancelled:
          throw Exception('Apple Sign In was cancelled by the user.');
        case AuthorizationStatus.error:
          throw Exception(
            'Apple Sign In error: ${result.error!.localizedDescription}',
          );
        default:
          throw Exception('Unknown Apple Sign In error.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String displayName) async {
    final userModel = UserModel(
      id: user.uid,
      email: user.email!,
      displayName: displayName,
      photoUrl: user.photoURL,
      isAdmin: false,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
  }

  // Get user model from Firestore
  Future<UserModel?> getUserModel(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (docSnapshot.exists) {
        return UserModel.fromJson(docSnapshot.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
    String userId, {
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (displayName != null) {
        updates['displayName'] = displayName;
        await currentUser?.updateDisplayName(displayName);
      }

      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
        await currentUser?.updatePhotoURL(photoUrl);
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updates);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw Exception('User is not authenticated.');
      }

      // Re-authenticate the user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Change the password
      await user.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount(String password) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw Exception('User is not authenticated.');
      }

      // Re-authenticate the user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete the user account
      await user.delete();
    } catch (e) {
      rethrow;
    }
  }
}
