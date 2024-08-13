import 'dart:convert';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saloon/GoogleApi/cloud_api.dart';
import 'package:saloon/LoginScreens/login_screen.dart';
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
  EmailOTP myauth = EmailOTP();

  bool isOtpVerified = false;
  bool isOtpEnabled = false;
  bool isOtpSending = false;  // Added state variable for OTP sending process
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
                 /* child: Image.asset(
                    'assets/Images/BlackOxLogo.png',
                    height: ScreenUtility.screenHeight * 0.17,
                    width: ScreenUtility.screenWidth * 0.8,
                    fit: BoxFit.fitWidth,
                  ),*/
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
                        isOtpEnabled = false;
                        isOtpVerified = false;
                        emailOtpController.clear();
                        isEmailValid = EmailValidator(errorText: 'Please correct email filled').isValid(value);
                      });
                    },
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Enter email address'),
                      EmailValidator(errorText: 'Please correct email filled'),
                    ]).call,
                    decoration: InputDecoration(
                        hintText: 'Email',
                        labelText: 'Email',
                        suffixIcon: isEmailValid
                            ? (isOtpSending
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                            : TextButton(
                          onPressed: isOtpSending
                              ? null
                              : () async {
                            setState(() {
                              isOtpSending = true;
                            });
                              // Send OTP if email does not exist
                              EmailOTP.config(
                                appEmail: "ox.black.passionit@gmail.com",
                                appName: "BlackOx",
                                otpLength: 6,
                                otpType: OTPType.numeric,
                                emailTheme: EmailTheme.v1
                              );

                              if (await EmailOTP.sendOTP(email: emailController.text) == true) {
                                setState(() {
                                  isOtpEnabled = true;
                                });
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("OTP has been sent"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Oops, OTP send failed"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            setState(() {
                              isOtpSending = false;
                            });
                          },
                          child: const Text("Send Otp"),
                        ))
                            : null,
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Colors.lightBlue,
                        ),
                        contentPadding:  const EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius:
                            BorderRadius.all(Radius.circular(9.0)))),
                  ),
                ),
                SizedBox(height: ScreenUtility.screenHeight * 0.02),
                Row(
                  children: [
                    SizedBox(
                      height: ScreenUtility.screenHeight * 0.04,
                      width: ScreenUtility.screenWidth * 0.4,
                      child: ElevatedButton(
                        onPressed: isOtpEnabled
                            ? () async {
                          if (EmailOTP.verifyOTP(otp: emailOtpController.text) == true) {
                            setState(() {
                              isOtpVerified = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("OTP is verified"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            setState(() {
                              isOtpVerified = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid OTP"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOtpVerified ? Colors.green : Colors.red,
                          minimumSize: Size(
                            ScreenUtility.screenWidth * 0.4,
                            ScreenUtility.screenWidth * 0.05,
                          ), // Increase button size
                        ),
                        child: const Text(
                          'Verify Otp',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtility.screenHeight * 0.03),
                    SizedBox(
                      height: ScreenUtility.screenHeight * 0.04,
                      width: ScreenUtility.screenWidth * 0.4,
                      child: TextFormField(
                        controller: emailOtpController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter the 6-digit code';
                          }
                          if (value.length != 6) {
                            return 'Code must be exactly 6 digits';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Otp',
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.grey,
                          ),

                        ),
                        enabled: isOtpEnabled,
                      ),
                    ),
                  ],
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
                      if (_formkey.currentState!.validate() && isOtpVerified) {
                        setState(() {
                          isSigningUp = true;
                        });
                        bool isRegistered = false;
                          // Register user on the web
                        try {
                          await _registerUser(
                            nameController.text,
                            passwordController.text,
                            emailController.text,
                            numberController.text,
                            _downloadUrl ?? '',
                          );
                          isRegistered =true;
                        }
                        catch(e)
                      {
                        isRegistered=false;
                        print(e);
                      }
                        setState(() {
                          isSigningUp = false;
                        });
                        if (isRegistered) {
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        } else {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Registration failed. Please try again')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Verify OTP and fill all fields correctly."),
                          backgroundColor: Colors.red,
                        ));
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
  Future<void> _registerUser(String name, String password, String email, String number,String imageUrl) async {
    final String apiUrl = 'http://localhost:3000/register';

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

      if (response.statusCode == 201) {
        // User registered successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User registered successfully')),
        );
      } else if (response.statusCode == 400) {
        // Email already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email already exists')),
        );
      } else {
        // Registration failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed')),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }


  bool _validatePassword(String password) {
    // Regular expression to check if password contains at least one letter, one number, and one special character
    final RegExp regex =
    RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return regex.hasMatch(password);
  }
}
