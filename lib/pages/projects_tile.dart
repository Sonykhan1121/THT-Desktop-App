import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProjectSubmissionPage extends StatefulWidget {
  @override
  _ProjectSubmissionPageState createState() => _ProjectSubmissionPageState();
}

class _ProjectSubmissionPageState extends State<ProjectSubmissionPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Your Project'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Project Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Project Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Technologies Used',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Completion Date',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Project Link',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Display default image or uploaded image
            _image == null
                ? Image.asset('assets/project_default.jpg', height: 500, width: 500, fit: BoxFit.cover)
                : Image.file(_image!, height: 500, width: 500, fit: BoxFit.cover),
            SizedBox(height: 30,),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Project Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {



                
                // Implement the logic to submit the project details
                print('Project Submitted Successfully');
              },
              child: Text('Submit Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
