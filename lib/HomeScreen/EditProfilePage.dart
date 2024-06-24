import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  final String profileImageURL; // Receive the profile image URL from ProfilePage
  EditProfilePage(this.profileImageURL);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileNumberController = TextEditingController();
  TextEditingController _dateOfBirthController = TextEditingController();
  String _imageUrl = ''; // Added variable to hold the image URL

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.profileImageURL; // Initialize _imageUrl with the received URL
    // Fetch the current user's data and populate the text controllers
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((snapshot) {
        if (snapshot.exists) {
          final userData = snapshot.data() as Map<String, dynamic>;
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _mobileNumberController.text = userData['mobile'] ?? '';
          _dateOfBirthController.text = userData['dob'] ?? '';
        }
      });
    }
  }

  void _updateUserProfile() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'mobileNumber': _mobileNumberController.text,
        'dateOfBirth': _dateOfBirthController.text,
        'imageUrl': _imageUrl, // Update the image URL in Firestore
      }).then((_) {
        // Pass the updated image URL back to ProfilePage
        Navigator.pop(context, _imageUrl);
      }).catchError((error) {
        print('Error updating profile: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Edit Profile'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            // Return to the previous page (ProfilePage) without saving changes
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              CupertinoTextField(
                controller: _firstNameController,
                placeholder: 'First Name',
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _lastNameController,
                placeholder: 'Last Name',
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Email',
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _mobileNumberController,
                placeholder: 'Mobile Number',
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.phone,
                inputFormatters: [LengthLimitingTextInputFormatter(15)],
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _dateOfBirthController,
                placeholder: 'Date of Birth',
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.text,
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SizedBox(height: 20.0),
              CupertinoButton.filled(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateUserProfile();
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
