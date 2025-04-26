import 'package:flutter/material.dart';
import 'package:mydesktopapp/services/firebase_service.dart';

import '../models/skills.dart';

class Whoami extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Whoami> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late TabController _tabController;
  final List<Skill> list=[];
  final TextEditingController shortDescription = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController jobDescriptionController = TextEditingController();
  final TextEditingController skillNameController = TextEditingController();
  final TextEditingController proficiencyLevelController = TextEditingController();

  // Example degree options for dropdown
  final List<String> degrees = ['BSc in Computer Science', 'BA in English', 'BSc in Engineering'];
  String? selectedDegree;
  bool _isLoading = false;

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
  Future<void> submitWhoAmI() async {

    if (shortDescription.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        addressController.text.isEmpty ||
        jobTitleController.text.isEmpty ||
        companyController.text.isEmpty ||
        startDateController.text.isEmpty ||
        endDateController.text.isEmpty ||
        jobDescriptionController.text.isEmpty ||
        selectedDegree == null || selectedDegree!.isEmpty ||list.isEmpty) {

      print('list length: ${list.length} ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields.'),
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

    try {



      try {
        await _firebaseService.savePersonalInformation(
          shortDescription: shortDescription.text.trim(),
          phone: phoneController.text.trim(),
          email: emailController.text.trim(),
          degree: selectedDegree.toString(),
          address: addressController.text.trim(),
        );
        print('✅ Personal Information saved.');
      } catch (e) {
        print('❌ Error saving Personal Information: $e');
      }

      try {
        await _firebaseService.saveExperience(
          jobTitle: jobTitleController.text.trim(),
          company: companyController.text.trim(),
          startDate: startDateController.text.trim(),
          endDate: endDateController.text.trim(),
          description: jobDescriptionController.text.trim(),
        );
        print('✅ Experience saved.');
      } catch (e) {
        print('❌ Error saving Experience: $e');
      }

      try {
        await _firebaseService.saveSkillsToFirebase(list); // where 'list' is List<Skill>
        print('✅ Skills saved.');
      } catch (e) {
        print('❌ Error saving Skills: $e');
      }



    } catch (e) {
      print('Upload submit error : $e');
    } finally {
      _isLoading = false;

      clearAllFields();

      if (mounted) {
        setState(() {});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Services Upload Successfully'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  void clearAllFields() {
    shortDescription.clear();
    phoneController.clear();
    emailController.clear();
    degreeController.clear();
    addressController.clear();
    jobTitleController.clear();
    companyController.clear();
    startDateController.clear();
    endDateController.clear();
    jobDescriptionController.clear();
    skillNameController.clear();
    proficiencyLevelController.clear();

    selectedDegree = null;

    // If you’re also using a skill list, you can clear that too


    setState(() {}); // Refresh the UI if needed
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
      body: _isLoading?Center(child: CircularProgressIndicator(),):TabBarView(
        controller: _tabController,
        children: [
          personalInfoTab(theme),
          experienceTab(theme),
          YourWidget(skills:list ,),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: submitWhoAmI,
        backgroundColor: Colors.teal,
        child: Icon(Icons.save),
      ),
    );
  }

  Widget personalInfoTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          buildTextField(
            controller: shortDescription,
            label: 'Short Description',
            icon: Icons.person,
            theme: theme,
            maxLines: 3,
          ),
          SizedBox(height: 10),
          buildTextField(
            controller: phoneController,
            label: 'Phone',
            icon: Icons.phone,
            theme: theme,
          ),
          SizedBox(height: 10),
          buildTextField(
            controller: emailController,
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
            controller: addressController,
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
          buildTextField(controller:jobTitleController,label: 'Job Title', theme: theme,icon: Icons.title),
          SizedBox(height: 10),
          buildTextField(controller:companyController,label: 'Company', theme:theme ,icon: Icons.add_circle),
          SizedBox(height: 10),
          buildTextField(controller: startDateController,label: 'Start Date', theme: theme,icon: Icons.calendar_month),
          SizedBox(height: 10),
          buildTextField(controller: endDateController,label: 'End Date', theme: theme,icon: Icons.calendar_month),
          SizedBox(height: 10),
          buildTextField(controller: jobDescriptionController,label: 'Description', theme: theme, maxLines: 3,icon: Icons.description),
        ],
      ),
    );
  }

  Widget skillsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          buildTextField(controller:skillNameController,label: 'Skill Name', theme: theme),
          SizedBox(height: 10),
          buildTextField(controller: proficiencyLevelController,label: 'Proficiency Level', theme: theme),
        ],
      ),
    );
  }

  Widget buildTextField({required TextEditingController controller,required String label, IconData? icon, required ThemeData theme, int maxLines = 1}) {
    return TextField(
      controller: controller,
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
class YourWidget extends StatefulWidget {
  List<Skill> skills;
   YourWidget({required this.skills,super.key});

  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
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