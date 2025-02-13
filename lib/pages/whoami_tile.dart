import 'package:flutter/material.dart';

class Whoami extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Whoami> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Example degree options for dropdown
  final List<String> degrees = ['BSc in Computer Science', 'BA in English', 'BSc in Engineering'];
  String? selectedDegree;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Who Am I?'),
        backgroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.teal.shade100,
          tabs: [
            Tab(text: 'Personal Information'),
            Tab(text: 'Experience'),
            Tab(text: 'Skills'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          personalInfoTab(theme),
          experienceTab(theme),
          skillsTab(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child: Icon(Icons.save),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget personalInfoTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          buildTextField(
            label: 'Short Description',
            icon: Icons.person,
            theme: theme,
            maxLines: 3,
          ),
          SizedBox(height: 10),
          buildTextField(
            label: 'Phone',
            icon: Icons.phone,
            theme: theme,
          ),
          SizedBox(height: 10),
          buildTextField(
            label: 'Email',
            icon: Icons.email,
            theme: theme,
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Degree',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: theme.primaryColor),
              ),
              prefixIcon: Icon(Icons.school, color: theme.primaryColor),
            ),
            value: selectedDegree,
            onChanged: (newValue) {
              setState(() {
                selectedDegree = newValue;
              });
            },
            items: degrees.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          buildTextField(
            label: 'Address',
            icon: Icons.home,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget experienceTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          buildTextField(label: 'Job Title', theme: theme,icon: Icons.title),
          SizedBox(height: 10),
          buildTextField(label: 'Company', theme:theme ,icon: Icons.add_circle),
          SizedBox(height: 10),
          buildTextField(label: 'Start Date', theme: theme,icon: Icons.calendar_month),
          SizedBox(height: 10),
          buildTextField(label: 'End Date', theme: theme,icon: Icons.calendar_month),
          SizedBox(height: 10),
          buildTextField(label: 'Description', theme: theme, maxLines: 3,icon: Icons.description),
        ],
      ),
    );
  }

  Widget skillsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          buildTextField(label: 'Skill Name', theme: theme),
          SizedBox(height: 10),
          buildTextField(label: 'Proficiency Level', theme: theme),
        ],
      ),
    );
  }

  Widget buildTextField({required String label, IconData? icon, required ThemeData theme, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor),
        ),
        prefixIcon: icon != null ? Icon(icon, color: theme.primaryColor) : null,
      ),
    );
  }
}
