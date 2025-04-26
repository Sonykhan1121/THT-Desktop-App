import 'package:flutter/material.dart';
import 'package:mydesktopapp/pages/social_link_preview.dart';
import 'package:mydesktopapp/services/firebase_service.dart';

class AdminContactInfoPage extends StatefulWidget {
  @override
  _AdminContactInfoPageState createState() => _AdminContactInfoPageState();
}

class _AdminContactInfoPageState extends State<AdminContactInfoPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController facebookLinkController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController instagramLinkController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    facebookLinkController.addListener(() => setState(() {}));
    linkedInController.addListener(() => setState(() {}));
    instagramLinkController.addListener(() => setState(() {}));
  }

  Future<void> submitContactInfo() async {
    if (_formKey.currentState!.validate()) {
      _isLoading = true;
      setState(() {});
      final contactInfo = {
        'companyName': companyNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'facebookLink': facebookLinkController.text.trim(),
        'linkedinLink': linkedInController.text.trim(),
        'instagramLink': instagramLinkController.text.trim(),
        'website': websiteController.text.trim(),
      };

      print('✅ Contact Info Saved: $contactInfo');

      await _firebaseService.saveContactInfo(
          companyName: contactInfo['companyName']!,
          email: contactInfo['email']!,
          phone: contactInfo['phone']!,
          address: contactInfo['address']!,
          facebookLink: contactInfo['facebookLink']!,
          linkedInLink: contactInfo['linkedinLink'],
          instagramLink: contactInfo['instagramLink'],
          website: contactInfo['website']!);

      // You can now save 'contactInfo' to Firestore or your backend.

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Contact Information Saved! ✅'),
        backgroundColor: Colors.green,
      ));

      // Optional: clear form
      _clearForm();
      _isLoading = false;
      setState(() {});
    }
  }

  void _clearForm() {
    companyNameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    facebookLinkController.clear();
    linkedInController.clear();
    instagramLinkController.clear();
    websiteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin: Set Contact Info'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildTextField(companyNameController, 'Company Name',
                        requiredField: true),
                    buildTextField(emailController, 'Email Address',
                        requiredField: true),
                    buildTextField(phoneController, 'Phone Number',
                        requiredField: true),
                    buildTextField(addressController, 'Address',
                        requiredField: true),
                    buildTextField(facebookLinkController, 'Facebook Link'),
                    if (facebookLinkController.text.isNotEmpty)
                      SocialLinkPreview(url: facebookLinkController.text),
                    buildTextField(linkedInController, 'LinkedIn Link'),
                    if (linkedInController.text.isNotEmpty)
                      SocialLinkPreview(url: linkedInController.text),
                    buildTextField(instagramLinkController, 'Instagram Link'),
                    if (instagramLinkController.text.isNotEmpty)
                      SocialLinkPreview(url: instagramLinkController.text),
                    buildTextField(websiteController, 'Website URL'),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: submitContactInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Save Contact Info',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: requiredField
            ? (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter $label';
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
