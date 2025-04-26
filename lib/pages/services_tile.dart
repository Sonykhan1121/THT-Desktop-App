import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';
import '../services/firebase_service.dart'; // Make sure this path matches where you save your ServiceModel

class MyServicesPage extends StatefulWidget {
  @override
  _MyServicesPageState createState() => _MyServicesPageState();
}

class _MyServicesPageState extends State<MyServicesPage> {
  final FirebaseService _firebaseService = FirebaseService();
  ServiceModel service = ServiceModel(title: '', description: '');
  final ImagePicker _picker = ImagePicker();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        service.image = File(pickedFile.path);
      });
    }
  }

  Future<void> submitService() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        service.image == null) {
      print('serice.image :${service.image?.path}');
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
      setState(() {});
    }

    try {
      // Use appropriate folder names for organization
      final imageUrl =
          await uploadFileToSupabase(service.image!);

      await _firebaseService.saveServices(
        title: titleController.text.toString(),
        description: descriptionController.text.toString(),
        imageUrl: imageUrl!,
      );
    } catch (e) {
      print('Upload submit error : $e');
    } finally {
      _isLoading = false;

      titleController.clear();
      descriptionController.clear();
      service.image = null;
      service.title = '';
      service.description = '';

      if (mounted) {
        setState(() {});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Services Upload Successfully'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<String?> uploadFileToSupabase(File file) async {
    final storage = Supabase.instance.client.storage;
    final fileExtension = file.path.split('.').last;
    final bucketName = 'admin-panel';

    try {
      // 1. List existing files in 'services/' folder to count them
      final existingFiles = await storage.from(bucketName).list(path: 'services');

      // 2. Count how many service_image_ files already exist
      final existingCount = existingFiles
          .where((f) => f.name.startsWith('service_image_'))
          .length;

      // 3. Generate next file name
      final nextIndex = existingCount + 1;
      final fileName = 'service_image_$nextIndex.$fileExtension';

      final pathInBucket = 'services/$fileName';

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
        title: Text("My Services"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (service.image != null)
                            Image.file(service.image!,
                                fit: BoxFit.cover, height: 250, width: 250),
                          if (service.image == null)
                            Image.asset('assets/default_profile.png',
                                fit: BoxFit.cover, height: 250, width: 250),
                          TextField(
                            controller: titleController,
                            onChanged: (val) => service.title = val,
                            decoration:
                                InputDecoration(labelText: 'Service Title'),
                          ),
                          TextField(
                            controller: descriptionController,
                            onChanged: (val) => service.description = val,
                            decoration:
                                InputDecoration(labelText: 'Description'),
                          ),
                          TextButton(
                            onPressed: _pickImage,
                            child: Text('Upload Image'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: submitService,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                          child: Text(
                            'Save Service',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
