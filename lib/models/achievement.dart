class Achievement {
  final String title;
  final String issuingOrganization;
  final String dateReceived;
  final String description;
  final List<String> imageUrls;

  // Constructor
  Achievement({
    required this.title,
    required this.issuingOrganization,
    required this.dateReceived,
    required this.description,
    required this.imageUrls,
  });

  // Convert an Achievement object to a Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'issuingOrganization': issuingOrganization,
      'dateReceived': dateReceived,
      'description': description,
      'imageUrls': imageUrls,
    };
  }

  // Convert a Map to an Achievement object (from Firestore)
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      title: map['title'],
      issuingOrganization: map['issuingOrganization'],
      dateReceived: map['dateReceived'],
      description: map['description'],
      imageUrls: List<String>.from(map['imageUrls']),
    );
  }
}
