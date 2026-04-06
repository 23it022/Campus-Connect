import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../errors/app_errors.dart';

/// Storage Service
/// Handles all Firebase Storage operations
/// Image upload, download, and file management

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload an image file to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadImage({
    required File file,
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      // Monitor upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw NetworkException('Failed to upload image: ${e.message}');
    } catch (e) {
      throw NetworkException('Failed to upload image: $e');
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw NetworkException('Failed to delete file: ${e.message}');
    } catch (e) {
      throw NetworkException('Failed to delete file: $e');
    }
  }

  /// Get download URL for a file path
  Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw NetworkException('Failed to get download URL: ${e.message}');
    } catch (e) {
      throw NetworkException('Failed to get download URL: $e');
    }
  }

  /// Get reference to a storage path
  Reference ref(String path) {
    return _storage.ref().child(path);
  }

  /// Generate a unique file name for uploads
  String generateFileName(String userId, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$userId\_$timestamp.$extension';
  }

  /// Generate path for user profile images
  String getUserProfileImagePath(String userId) {
    return 'users/$userId/profile.jpg';
  }

  /// Generate path for post images
  String getPostImagePath(String userId, String postId) {
    return 'posts/$userId/$postId.jpg';
  }

  /// Generate path for event images
  String getEventImagePath(String eventId) {
    return 'events/$eventId.jpg';
  }

  /// Generate file path for group images
  String _getGroupImagePath(String groupId) {
    return 'groups/$groupId/${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  /// Upload post image
  Future<String> uploadPostImage({
    required String userId,
    required String imagePath,
  }) async {
    final path = 'posts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadImage(file: File(imagePath), path: path);
  }

  /// Generate path for group images
  String getGroupImagePath(String groupId) {
    return 'groups/$groupId.jpg';
  }
}
