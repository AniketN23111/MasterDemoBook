import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:passionHub/GoogleApi/cloud_api.dart';
import 'package:passionHub/LoginScreens/login_screen.dart';
import 'package:http/http.dart' as http;

import '../Constants/screen_utility.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController emailOtpController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  bool isSigningUp = false;
  bool isEmailValid = false;
  CloudApi? cloudApi;
  bool _uploading = false;
  String? _downloadUrl;// Added state variable for email validity

  Future<void> _loadCloudApi() async {
    String jsonCredentials =
    await rootBundle.loadString('assets/GoogleJson/clean-emblem-394910-8dd84a4022c3.json');
    setState(() {
      cloudApi = CloudApi(jsonCredentials);
    });
  }
  Future<void> _pickAndUploadImage() async {
    _loadCloudApi();
    setState(() {
      _uploading = true; // Start uploading, show progress indicator
    });

    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file picked')),
      );
      setState(() {
        _uploading = false; // Cancel upload, hide progress indicator
      });
      return;
    }

    if (cloudApi == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud API not initialized')),
      );
      setState(() {
        _uploading = false; // Cancel upload, hide progress indicator
      });
      return;
    }

    Uint8List imageBytes = await pickedFile.readAsBytes();
    String fileName = pickedFile.name; // Provide a default name

    try {
      await cloudApi!.save(fileName, imageBytes);
      final downloadUrl = await cloudApi!.getDownloadUrl(fileName);

      // Store the image bytes to display it
      setState(() {
        _downloadUrl = downloadUrl;
        _uploading = false; // Upload finished, hide progress indicator
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      setState(() {
        _uploading = false; // Error in upload, hide progress indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(20.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    controller: nameController,
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Enter Name'),
                      MinLengthValidator(3,
                          errorText: 'Minimum 3 character filled name'),
                    ]).call,
                    decoration: const InputDecoration(
                        hintText: 'Enter Name',
                        labelText: 'Enter Name',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.green,
                        ),
                        contentPadding:  EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius:
                            BorderRadius.all(Radius.circular(9.0)))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Password';
                      }
                      // Check if password meets the criteria
                      bool isValidPassword = _validatePassword(value);
                      if (!isValidPassword) {
                        return 'Password must have a minimum of 8 characters and include letters, numbers, and special characters.';
                      }
                      return null; // Validation passed
                    },
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: 'Password',
                        labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.password,
                          color: Colors.lightBlue,
                        ),
                        contentPadding:  EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius:
                            BorderRadius.all(Radius.circular(9.0)))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    controller: numberController,
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Enter mobile number'),
                      PatternValidator(r'^[0-9]{10}$',
                          errorText: 'Enter valid 10-digit mobile number'),
                    ]).call,
                    decoration: const InputDecoration(
                        hintText: 'Mobile',
                        labelText: 'Mobile',
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.grey,
                        ),
                        contentPadding:  EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius:
                            BorderRadius.all(Radius.circular(9)))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: emailController,
                    onChanged: (value) {
                      setState(() {
                        emailOtpController.clear();
                        isEmailValid = EmailValidator(errorText: 'Please correct email filled').isValid(value);
                      });
                    },
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Enter email address'),
                      EmailValidator(errorText: 'Please correct email filled'),
                    ]).call,
                    decoration: const InputDecoration(
                        hintText: 'Email',
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.lightBlue,
                        ),
                        contentPadding:  EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius:
                            BorderRadius.all(Radius.circular(9.0)))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _uploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Upload Image',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_downloadUrl != null)
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Uploaded Image:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Image.network(
                          _downloadUrl!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: ScreenUtility.screenHeight * 0.05),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {
                        setState(() {
                          isSigningUp = true;
                        });
                        try {
                          await _registerUser(
                            nameController.text,
                            passwordController.text,
                            emailController.text,
                            numberController.text,
                            _downloadUrl ?? '',
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("An error occurred: $e")),
                          );
                          setState(() {
                            isSigningUp = false;
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Fill all fields correctly."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(
                        ScreenUtility.screenWidth * 0.8,
                        ScreenUtility.screenHeight * 0.05,
                      ), // Increase button size
                    ),
                    child: isSigningUp
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtility.screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _registerUser(
      String name, String password, String email, String number, String imageUrl) async {
    const String apiUrl = 'http://mentor.passionit.com/mentor-api/register';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'password': password,
          'email': email,
          'number': number,
          'imageUrl': imageUrl,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        // User registered successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User registered successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to login screen on successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else if (response.statusCode == 400) {
        // Email already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email already exists'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isSigningUp = false;
        });
      } else {
        // Registration failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isSigningUp = false;
        });
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      setState(() {
        isSigningUp = false;
      });
    }
  }


  bool _validatePassword(String password) {
    // Regular expression to check if password contains at least one letter, one number, and one special character
    final RegExp regex =
    RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return regex.hasMatch(password);
  }
}
