// lib/services/firebase_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_profile.dart';
//214275103469-0a7ogu325874s43gs3prvm21d572roin.apps.googleusercontent.com
class FirebaseService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String destinationFolder) async {
    return "path/test1.png";
    try {
      // Extract just the file name from the full path
      String fileName = file.path.split('/').last;

      // Create a reference with a proper path in Firebase Storage
      final ref = _storage.ref().child('$destinationFolder/$fileName');

      // Upload the file
      UploadTask uploadTask = ref.putFile(file);

      // Await upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print("Firebase upload error: ${e.message}");
      throw Exception("Upload failed: ${e.code} - ${e.message}");
    } catch (e) {
      print("Unknown upload error: $e");
      throw Exception("Unexpected error during upload");
    }
  }

  Future<UserProfile> saveUserProfile({
    required String name,
    required String designation,
    required String imageUrl,
    required String pdfUrl,
  }) async {
    final docRef = await _firestore.collection('users').add({
      'name': name,
      'designation': designation,
      'imageUrl': imageUrl,
      'pdfUrl': pdfUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return UserProfile(
      id: docRef.id,
      name: name,
      designation: designation,
      imageUrl: imageUrl,
      pdfUrl: pdfUrl,
    );
  }
}
