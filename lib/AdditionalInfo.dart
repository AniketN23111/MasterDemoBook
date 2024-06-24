import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:saloon/HomeScreen/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final User user;

  AdditionalInfoScreen({required this.user});

  @override
  _AdditionalInfoScreenState createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  DateTime? selectedDate; // To store the selected date

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    )) ?? DateTime.now();
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
  }

  @override
  void initState() {
    super.initState();
    // Parse the displayName to extract first and last name
    String displayName = widget.user.displayName ?? '';
    List<String> nameComponents = displayName.split(' ');
    if (nameComponents.length >= 2) {
      firstNameController.text = nameComponents[0];
      lastNameController.text = nameComponents.sublist(1).join(' ');
    }
    // Set the email
    emailController.text = widget.user.email ?? '';
    mobileController.text=widget.user.phoneNumber??'';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 200),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: dobController,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context); // Show the date picker
                  },
                ),
              ),
            ),
            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10)
              ],
              decoration: InputDecoration(labelText: 'Mobile Number'),
            ),
            ElevatedButton(
              onPressed: () async{
                String firstName = firstNameController.text;
                String lastName = lastNameController.text;
                String email = emailController.text;
                String dob = dobController.text;
                String mobile = mobileController.text;

                // Create a map of user data
                Map<String, dynamic> userData = {
                  'firstName': firstName,
                  'lastName': lastName,
                  'email': email,
                  'dob': dob,
                  'mobile': mobile,
                };

                // Reference to the user's document in Firestore
                DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(widget.user.uid);

                // Set the user data in Firestore
                await userDoc.set(userData);

                // Navigate to the homepage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      user: widget.user,
                    ),
                  ),
                );
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
