class Skill {
  final String name;
  final String proficiency;

  Skill({required this.name, required this.proficiency});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'proficiency': proficiency,
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      name: map['name'] ?? '',
      proficiency: map['proficiency'] ?? '',
    );
  }
}
