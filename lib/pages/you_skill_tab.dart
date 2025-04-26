import 'package:flutter/material.dart';

import '../models/skills.dart';

class yourskilltab extends StatefulWidget {
  List<Skill> skills;
  yourskilltab({required this.skills,super.key});

  @override
  _yourskilltabState createState() => _yourskilltabState();
}

class _yourskilltabState extends State<yourskilltab> {
  final TextEditingController skillNameController = TextEditingController();
  final TextEditingController proficiencyLevelController = TextEditingController();



  void addSkill() {
    final name = skillNameController.text.trim();
    final level = proficiencyLevelController.text.trim();

    if (name.isNotEmpty && level.isNotEmpty) {
      setState(() {
        widget.skills.add(Skill(name: name, proficiency: level));
        skillNameController.clear();
        proficiencyLevelController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter both Skill Name and Proficiency Level.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget skillsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextField(
              controller: skillNameController,
              label: 'Skill Name',
              theme: theme),
          SizedBox(height: 10),
          buildTextField(
              controller: proficiencyLevelController,
              label: 'Proficiency Level',
              theme: theme),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: addSkill,
            icon: Icon(Icons.add),
            label: Text('Add Skill'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Added Skills:',
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.skills.length,
            itemBuilder: (context, index) {
              final skill = widget.skills[index];
              return ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.teal),
                title: Text(skill.name),
                subtitle: Text('Proficiency: ${skill.proficiency}'),
              );
            },
          ),
        ],
      ),
    );
  }
  // Your buildTextField method here
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required ThemeData theme,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Skills')),
      body: skillsTab(theme),
    );
  }
}