class ProjectModel {
  final String? id;
  final String title;
  final String description;
  final List<String> technologies;
  final String builtBy;
  final String youtubeLink;
  final String githubLink;
  final List<String> images;

  ProjectModel({
    this.id,
    required this.title,
    required this.description,
    required this.technologies,
    required this.builtBy,
    required this.youtubeLink,
    required this.githubLink,
    required this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'technologies': technologies,
      'builtBy': builtBy,
      'youtubeLink': youtubeLink,
      'githubLink': githubLink,
      'images': images,
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      technologies: List<String>.from(map['technologies'] ?? []),
      builtBy: map['builtBy'] ?? '',
      youtubeLink: map['youtubeLink'] ?? '',
      githubLink: map['githubLink'] ?? '',
      images: List<String>.from(map['images'] ?? []),
    );
  }
}
