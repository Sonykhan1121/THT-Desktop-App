// lib/services/firebase_service.dart

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/service_model.dart';
import '../models/user_profile.dart';

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;


  Future<String?> uploadFileToSupabase(File file, String fileName) async {
    final storage = Supabase.instance.client.storage;

    final pathInBucket = 'uploads/$fileName'; // Folder inside the bucket
    final bucketName = 'Admin-Panel'; // e.g., 'uploads'

    try {
      final response = await storage.from(bucketName).upload(pathInBucket, file);

      if (response.isNotEmpty) {
        final publicUrl = storage.from(bucketName).getPublicUrl(pathInBucket);
        print('✅ Upload Success: $publicUrl');
        return publicUrl;
      } else {
        print('❌ Upload failed.');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
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
  Future<dynamic> saveServices({
    required String title,
    required String description,
    required String imageUrl,
}) async{
    final docRef = await _firestore.collection('services').add({
      'title': title,
      'description': description,
      'imageUrl' :imageUrl,
    });
    return docRef;
  }
}
