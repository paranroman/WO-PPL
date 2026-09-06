import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadKtmImage(File file, String userId) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';

      final String filePath = 'users/ktm_uploads/$userId/$fileName';
      final Reference ref = _storage.ref().child(filePath);

      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Error uploading KTM image: $e');
      return null;
    }
  }

  Future<String?> uploadProfilePicture(File file, String userId) async {
    try {
      final String filePath = 'users/profile_pictures/$userId/profile.jpg';

      final Reference ref = _storage.ref().child(filePath);

      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  Future<String?> uploadDocument(
    File file,
    String eventId,
    String fileName,
  ) async {
    try {
      final String filePath = 'events/$eventId/$fileName';

      final Reference ref = _storage.ref().child(filePath);

      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Error uploading document: $e');
      return null;
    }
  }

  Future<void> deleteDocument(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } on FirebaseException catch (e) {
      print('Error deleting document: $e');
    }
  }
}
