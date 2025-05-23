// lib/services/firebase_service.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mydesktopapp/models/personal_information.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/achievement.dart';
import '../models/project_model.dart';
import '../models/skills.dart';
import '../models/user_profile.dart';
import '../models/workexperience.dart';

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;

  Future<String?> uploadFileToSupabase(File file, String fileName) async {
    final storage = Supabase.instance.client.storage;

    final pathInBucket = 'uploads/$fileName'; // Folder inside the bucket
    final bucketName = 'Admin-Panel'; // e.g., 'uploads'

    try {
      final response =
          await storage.from(bucketName).upload(pathInBucket, file);

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

  Future<personalInformation> savePersonalInformation({
    required String shortDescription,
    required String phone,
    required String email,
    required String degree,
    required String address,
  }) async {
    final docRef = await _firestore.collection('personalInformation').add({
      'shortDescription': shortDescription,
      'phone': phone,
      'email': email,
      'degree': degree,
      'address': address,
    });

    return personalInformation(
        id: docRef.id,
        shortDescription: shortDescription,
        phone: phone,
        email: email,
        degree: degree,
        address: address);
  }

  Future<WorkExperience> saveExperience({
    required String jobTitle,
    required String company,
    required String startDate,
    required String endDate,
    required String description,
  }) async {
    final docRef = await _firestore.collection('experiences').add({
      'jobTitle': jobTitle,
      'company': company,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    });

    return WorkExperience(
        id: docRef.id,
        jobTitle: jobTitle,
        company: company,
        startDate: startDate,
        endDate: endDate,
        description: description);
  }

  Future<void> saveSkillsToFirebase(List<Skill> skills) async {
    try {
      final skillsCollection = FirebaseFirestore.instance.collection('skills');

      for (Skill skill in skills) {
        await skillsCollection.add(skill.toMap());
      }

      print('✅ Skills uploaded successfully.');
    } catch (e) {
      print('❌ Error uploading skills: $e');
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
  }) async {
    final docRef = await _firestore.collection('services').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    });
    return docRef;
  }

  Future<DocumentReference> saveProject({
    required ProjectModel project,
  }) async {
    final docRef = await _firestore.collection('projects').add(project.toMap());
    return docRef;
  }

  Future<dynamic> saveContactInfo({
    required String companyName,
    required String email,
    required String phone,
    required String address,
    String? facebookLink,
    String? linkedInLink,
    String? instagramLink,
    String? website,
  }) async {
    try {
      final docRef = await _firestore.collection('about').add({
        'companyName': companyName,
        'email': email,
        'phone': phone,
        'address': address,
        'facebookLink': facebookLink ?? '',
        'linkedInLink': linkedInLink ?? '',
        'instagramLink': instagramLink ?? '',
        'website': website ?? '',
        'timestamp':
            FieldValue.serverTimestamp(), // Optional: to track creation time
      });

      print('✅ Contact Info Saved with ID: ${docRef.id}');
      return docRef;
    } catch (e) {
      print('❌ Error saving contact info: $e');
      rethrow;
    }
  }

  Future<dynamic> addAchievement(Achievement achievement) async {
    try {
      final docRef =
          await _firestore.collection('achievement').add(achievement.toMap());

      return docRef.id;
    } catch (e) {
      print('Error uploading achievement: $e');
      return null;
    }
  }
}
