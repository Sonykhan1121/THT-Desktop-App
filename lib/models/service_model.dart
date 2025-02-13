import 'dart:io';

class ServiceModel {
  String title;
  String description;
  File? image;

  ServiceModel({required this.title, required this.description, this.image});
}

