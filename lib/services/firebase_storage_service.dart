// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final String fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.${path.extension(imageFile.path)}';
      final Reference reference = _storage
          .ref()
          .child('profile_images')
          .child(fileName);

      final UploadTask uploadTask = reference.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Upload proverb background image
  Future<String> uploadProverbImage(File imageFile) async {
    try {
      final String fileName = '${_uuid.v4()}.${path.extension(imageFile.path)}';
      final Reference reference = _storage
          .ref()
          .child('proverb_images')
          .child(fileName);

      final UploadTask uploadTask = reference.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Upload category icon
  Future<String> uploadCategoryIcon(File imageFile) async {
    try {
      final String fileName = '${_uuid.v4()}.${path.extension(imageFile.path)}';
      final Reference reference = _storage
          .ref()
          .child('category_icons')
          .child(fileName);

      final UploadTask uploadTask = reference.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Delete image by URL
  Future<void> deleteImageByUrl(String imageUrl) async {
    try {
      final Reference reference = _storage.refFromURL(imageUrl);
      await reference.delete();
    } catch (e) {
      rethrow;
    }
  }
}
