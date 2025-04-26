
import 'dart:io';
import 'package:flutter/material.dart';

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


}
