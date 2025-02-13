import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/service_model.dart'; // Make sure this path matches where you save your ServiceModel

class MyServicesPage extends StatefulWidget {
  @override
  _MyServicesPageState createState() => _MyServicesPageState();
}

class _MyServicesPageState extends State<MyServicesPage> {
  ServiceModel service = ServiceModel(title: '', description: '');
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        service.image = File(pickedFile.path);
      });
    }
  }

  void _saveService() {
    // Implement your saving functionality here
    // For now, it just prints to the console
    print('Service saved: ${service.title}, ${service.description}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Services"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
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
                      Image.file(service.image!, fit: BoxFit.cover, height: 250, width: 250),
                    if (service.image == null)
                      Image.asset('assets/default_profile.png', fit: BoxFit.cover, height: 250, width: 250),
                    TextField(
                      onChanged: (val) => service.title = val,
                      decoration: InputDecoration(labelText: 'Service Title'),
                    ),
                    TextField(
                      onChanged: (val) => service.description = val,
                      decoration: InputDecoration(labelText: 'Description'),
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
                    onPressed: _saveService,
                    child: Text('Save Service',style: TextStyle(color: Colors.black),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
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
