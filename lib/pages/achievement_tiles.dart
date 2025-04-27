import 'dart:io'; // To work with files

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mydesktopapp/services/firebase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/achievement.dart'; // To pick images

class AchievementsPage extends StatefulWidget {
  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final FirebaseService _firebaseService = FirebaseService();

  final _formKey = GlobalKey<FormState>();
  List<File> _images = [];
  bool _isLoading = false;

  // Controllers for form fields
  final _titleController = TextEditingController();
  final _organizationController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Pick image
  final ImagePicker _picker = ImagePicker();

  // Function to pick multiple images
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  // Function to submit the form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields...'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    _isLoading = true;
    if (mounted) {
      setState(() {}); // Rebuild the widget to show loading indicator
    }

    try {
      // 2. Upload images to Firebase Storage or Supabase (your existing function)
      List<String> imageUrls = [];
      for (final img in _images) {
        final url = await uploadFileToSupabase(
            img); // Or any backend service like Firebase Storage
        if (url != null) {
          imageUrls.add(url);
        }
      }

      final achievement = Achievement(
        title: _titleController.text,
        issuingOrganization: _organizationController.text,
        dateReceived: _dateController.text,
        description: _descriptionController.text,
        imageUrls: imageUrls, // Placeholder for image URLs
      );

      // 4. Save achievement data to Firestore (or your database)
      await _firebaseService.addAchievement(
          achievement); // Assuming FirestoreService() handles Firestore uploads
    } catch (e) {
      print('Upload submit error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload achievement. Please try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }

      clearFields();

      // Success message after submission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Achievement Uploaded Successfully'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void clearFields() {
    _titleController.clear();
    _organizationController.clear();
    _dateController.clear();
    _descriptionController.clear();
    _images.clear();
  }

  Future<String?> uploadFileToSupabase(File file) async {
    final storage = Supabase.instance.client.storage;
    final fileExtension = file.path.split('.').last;
    final bucketName = 'admin-panel';

    try {
      // 1. List existing files in 'services/' folder to count them
      final existingFiles =
          await storage.from(bucketName).list(path: 'achievements');

      // 2. Count how many service_image_ files already exist
      final existingCount = existingFiles
          .where((f) => f.name.startsWith('achievement_image_'))
          .length;

      // 3. Generate next file name
      final nextIndex = existingCount + 1;
      final fileName = 'achievement_image_$nextIndex.$fileExtension';

      final pathInBucket = 'achievements/$fileName';

      // 4. Upload file
      final response = await storage.from(bucketName).upload(
            pathInBucket,
            file,
            fileOptions: const FileOptions(upsert: false),
          );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Achievements', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey, // Assign form key for validation
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title of Achievement',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _organizationController,
                      decoration: InputDecoration(
                        labelText: 'Issuing Organization',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the issuing organization';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date Received',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                      onTap: () async {
                        FocusScope.of(context)
                            .requestFocus(FocusNode()); // Close the keyboard
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dateController.text =
                                "${pickedDate.toLocal()}".split(' ')[0];
                          });
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // Add button to select multiple images
                    InkWell(
                      onTap: _pickImages,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.white),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Display selected images as icons
                    _images.isNotEmpty
                        ? GridView.builder(
                            shrinkWrap: true,
                            itemCount: _images.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                            ),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  // Add your onTap logic here (optional: preview image)
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _images[index],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(),
                    SizedBox(height: 10),
                    // Submit button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      child: Text('Add Achievement',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
