import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mydesktopapp/providers/profileprovider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/firebase_service.dart'; // For picking images
// For picking files

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  File? _image;
  File? _pdfFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

// Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

// Pick a PDF file
  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _pdfFile = File(result.files.single.path!);
        });
      } else {
        print('No PDF selected');
      }
    } catch (e) {
      print('Error picking PDF: $e');
    }
  }

  Future<void> submitProfile() async {

    if (_nameController.text.isEmpty ||
        _designationController.text.isEmpty ||
        _image == null ||
        _image == null) {
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

    print('imgfile: ${_image?.path}');
    print('pdffile: ${_pdfFile?.path}');
    try {
      // Use appropriate folder names for organization
      final imageUrl = await uploadFileToSupabase(_image!);
      final pdfUrl = await uploadFileToSupabase(_pdfFile!);

      await _firebaseService.saveUserProfile(
        name: _nameController.text.toString(),
        designation: _designationController.text.toString(),
        imageUrl: imageUrl!,
        pdfUrl: pdfUrl!,
      );
    } catch (e) {
      print('Upload submit error : $e');
    } finally {
      _isLoading = false;

      _nameController.clear();
      _designationController.clear();
      _image = null;
      _pdfFile = null;
      if (mounted) {
        setState(() {});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Documents Upload Successfully'),
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
      final existingFiles = await storage.from(bucketName).list(path: 'profile');

      // 2. Count how many service_image_ files already exist
      final existingCount = existingFiles
          .where((f) => f.name.startsWith('profile_image_'))
          .length;

      // 3. Generate next file name
      final nextIndex = existingCount + 1;
      final fileName = 'profile_image_$nextIndex.$fileExtension';

      final pathInBucket = 'profile/$fileName';

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
    return Consumer<ProfileProvider>(
      builder: (BuildContext context, ProfileProvider value, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Edit Profile"),
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
                      Text(
                        "Profile Information",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _designationController,
                        decoration: InputDecoration(
                          labelText: "Designation",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : AssetImage("assets/default_profile.png")
                                  as ImageProvider,
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          "Upload new photo",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildFilePicker("Upload Image", _pickImage),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Accepted file types: jpg, jpeg, png, gif, heic, heif",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildFilePicker("Upload PDF", _pickPDF),
                      SizedBox(height: 20),
                      Text(
                        _pdfFile != null
                            ? 'Selected PDF: ${_pdfFile!.path.split('/').last}'
                            : 'No PDF file selected',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed:submitProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                          ),
                          child: Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildFilePicker(String label, Function onTap) {
    return InkWell(
      onTap: () => onTap(),
      child: DottedBorder(
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: Colors.teal)),
          ),
        ),
      ),
    );
  }
}

class DottedBorder extends StatelessWidget {
  final Widget child;

  DottedBorder({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border:
            Border.all(color: Colors.teal, style: BorderStyle.solid, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
