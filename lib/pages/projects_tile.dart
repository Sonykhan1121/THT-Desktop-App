import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/project_model.dart';
import '../services/firebase_service.dart';

class ProjectSubmissionPage extends StatefulWidget {
  @override
  _ProjectSubmissionPageState createState() => _ProjectSubmissionPageState();
}

class _ProjectSubmissionPageState extends State<ProjectSubmissionPage> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  YoutubePlayerController? _ytController;
  String? _videoId;
  Map<String, dynamic>? _githubRepoData;

  final List<File> _images = [];

  final TextEditingController projectTitleController = TextEditingController();
  final TextEditingController projectDescriptionController =
      TextEditingController();
  final TextEditingController technologyController = TextEditingController();
  final TextEditingController builtByController = TextEditingController();
  final TextEditingController youtubeLinkController = TextEditingController();
  final TextEditingController githubLinkController = TextEditingController();

  List<String> selectedTechnologies = [];
  final List<String> techSuggestions = [
    'Flutter',
    'Dart',
    'Firebase',
    'React',
    'Node.js',
    'Python',
    'Machine Learning',
    'TensorFlow',
    'Supabase',
    'MongoDB',
    'Express.js',
    'MySQL',
    'AWS',
    'Docker'
  ];

  String? getYoutubeVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    } else if (uri.host.contains('youtube.com') &&
        uri.queryParameters['v'] != null) {
      return uri.queryParameters['v'];
    }
    return null;
  }

  void handleYoutubeLink(String url) {
    final id = getYoutubeVideoId(url);
    if (id != null) {
      setState(() {
        _videoId = id;

        // Dispose previous controller if exists
        _ytController?.dispose();

        _ytController = YoutubePlayerController(
          initialVideoId: id,
          flags: YoutubePlayerFlags(
            autoPlay: false,
            mute: true,
          ),
        );
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _images
            .addAll(result.paths.whereType<String>().map((path) => File(path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _addTechnology(String tech) {
    if (!selectedTechnologies.contains(tech)) {
      setState(() {
        selectedTechnologies.add(tech);
      });
    }
    technologyController.clear();
  }

  Future<Map<String, dynamic>?> fetchGitHubRepo(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.host.contains('github.com')) return null;

    final segments = uri.pathSegments;
    if (segments.length < 2) return null;

    final username = segments[0];
    final repo = segments[1];

    final apiUrl = 'https://api.github.com/repos/$username/$repo';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Error fetching GitHub repo: $e");
    }

    return null;
  }

  Future<String?> uploadFileToSupabase(File file) async {
    final storage = Supabase.instance.client.storage;
    final fileExtension = file.path.split('.').last;
    final bucketName = 'admin-panel';

    try {
      // 1. List existing files in 'services/' folder to count them
      final existingFiles =
          await storage.from(bucketName).list(path: 'projects');

      // 2. Count how many service_image_ files already exist
      final existingCount = existingFiles
          .where((f) => f.name.startsWith('project_image_'))
          .length;

      // 3. Generate next file name
      final nextIndex = existingCount + 1;
      final fileName = 'project_image_$nextIndex.$fileExtension';

      final pathInBucket = 'projects/$fileName';

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

  Future<void> projectSubmit() async {
    try {
      // Validation
      if (projectTitleController.text.isEmpty ||
          projectDescriptionController.text.isEmpty ||
          selectedTechnologies.isEmpty ||
          _images.isEmpty ||
          githubLinkController.text.isEmpty ||
          youtubeLinkController.text.isEmpty ||
          builtByController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all required fields!')),
        );
        return;
      }
      _isLoading = true;
      setState(() {});

      // Upload images to Supabase
      List<String> imageUrls = [];
      for (final img in _images) {
        final url = await uploadFileToSupabase(img);
        if (url != null) imageUrls.add(url);
      }

      // Create a ProjectModel object
      final project = ProjectModel(
        title: projectTitleController.text.trim(),
        description: projectDescriptionController.text.trim(),
        technologies: selectedTechnologies,
        builtBy: builtByController.text.trim(),
        youtubeLink: youtubeLinkController.text.trim(),
        githubLink: githubLinkController.text.trim(),
        images: imageUrls,
      );

      // Print the project data for checking
      print('Submitting Project:');

      // TODO: Upload projectData to your backend (Firestore / Supabase / etc.)

      await _firebaseService.saveProject(project: project);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project Submitted Successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear all fields after success
      projectTitleController.clear();
      projectDescriptionController.clear();
      technologyController.clear();
      builtByController.clear();
      githubLinkController.clear();
      youtubeLinkController.clear();
      selectedTechnologies.clear();
      _images.clear();
      _githubRepoData = null;
      _videoId = null;
      _ytController?.dispose();
      _ytController = null;

      _isLoading = false;
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit project: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Your Project'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField(projectTitleController, 'Project Title'),
                  SizedBox(height: 10),
                  buildTextField(
                      projectDescriptionController, 'Project Description',
                      maxLines: 5),
                  SizedBox(height: 10),
                  Text('Technologies Used:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: technologyController,
                    decoration: InputDecoration(
                      labelText: 'Add Technology',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) _addTechnology(value.trim());
                    },
                  ),
                  SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: selectedTechnologies
                        .map((tech) => Chip(
                              label: Text(tech),
                              deleteIcon: Icon(Icons.close),
                              onDeleted: () {
                                setState(() {
                                  selectedTechnologies.remove(tech);
                                });
                              },
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 10),
                  Text('Suggestions:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: techSuggestions
                        .map((tech) => ActionChip(
                              label: Text(tech),
                              onPressed: () => _addTechnology(tech),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 20),
                  buildTextField(
                      builtByController, 'Built By (e.g. Dolon, Sony)'),
                  SizedBox(height: 20),
                  buildTextField(
                    githubLinkController,
                    'github link',
                    onChanged: (val) async {
                      final repo = await fetchGitHubRepo(val);
                      if (repo != null) {
                        setState(() {
                          _githubRepoData = repo;
                        });
                      }
                    },
                  ),
                  if (_githubRepoData != null)
                    buildGithubPreview(_githubRepoData!),
                  SizedBox(height: 20),
                  buildTextField(
                    youtubeLinkController,
                    'YouTube Link',
                    onChanged: handleYoutubeLink,
                  ),
                  SizedBox(height: 20),
                  if (_videoId != null && _ytController != null) ...[
                    SizedBox(height: 20),
                    YoutubePlayerBuilder(
                      player: YoutubePlayer(
                        controller: _ytController!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.teal,
                      ),
                      builder: (context, player) => player,
                    ),
                  ],
                  SizedBox(
                    height: 20,
                  ),
                  Text('Project Images:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  _images.isEmpty
                      ? Text('No images selected.')
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _images.asMap().entries.map((entry) {
                            int idx = entry.key;
                            File img = entry.value;
                            return Stack(
                              children: [
                                InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                img,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Image.file(img,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover)),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(idx),
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.red,
                                      child: Icon(Icons.close,
                                          size: 16, color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            );
                          }).toList(),
                        ),
                  SizedBox(height: 20),
                  buildPickImagesButton(),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: projectSubmit,
                      child: Text(
                        'Submit Project',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildGithubPreview(Map<String, dynamic> repo) {
    return Card(
      margin: EdgeInsets.only(top: 16),
      child: ListTile(
        title: Text(repo['full_name'] ?? ''),
        subtitle: Text(repo['description'] ?? 'No description'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 4),
            Text('${repo['stargazers_count'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget buildPickImagesButton() {
    return ElevatedButton.icon(
      onPressed: _pickMultipleImages,
      icon: Icon(Icons.add_photo_alternate),
      label: Text('Add Images'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    void Function(String)? onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
