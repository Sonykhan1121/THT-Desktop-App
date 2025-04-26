// lib/providers/profile_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mydesktopapp/services/googleauthclient.dart';

import '../services/firebase_service.dart';


class ProfileProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  String name = '';
  String designation = '';
  File? imageFile;
  File? pdfFile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void updateName(String value) {
    name = value;
    notifyListeners();
  }

  void updateDesignation(String value) {
    designation = value;
    notifyListeners();
  }

  void setImageFile(File file) {
    imageFile = file;
    notifyListeners();
  }

  void setPdfFile(File file) {
    pdfFile = file;
    notifyListeners();
  }

  Future<void> submitProfile() async {

    _isLoading = true;
    notifyListeners();

    print('imgfile: ${imageFile?.path}');
    print('pdffile: ${pdfFile?.path}');
    try {
      // Use appropriate folder names for organization
      final imageUrl = await uploadToGoogleDrive(imageFile!);
      final pdfUrl = await uploadToGoogleDrive(pdfFile!);

      await _firebaseService.saveUserProfile(
        name: name,
        designation: designation,
        imageUrl: imageUrl,
        pdfUrl: pdfUrl,
      );
    } catch (e) {
      print('Upload submit error : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
