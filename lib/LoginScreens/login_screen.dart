import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:passionHub/HomeScreen/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/screen_utility.dart';
import '../Admin/admin_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formkey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  List<List<dynamic>>? userData;

  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
  }


  Future<void> _login() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        _isLoggingIn = true;
      });
      try {
        String enteredEmail = emailController.text.toString();
        String enteredPassword = passwordController.text.toString();

        // Make a POST request to the server for login
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/login'), // Replace with your server URL
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': enteredEmail, 'password': enteredPassword}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['isAdmin'] == true) {
            await _storeDetailsInPrefs(true, true);
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminPage()),
            );
          } else if (data['isUser'] == true) {
            await _storeDetailsInPrefs(true, false);
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          } else {
            await _storeDetailsInPrefs(false, false);
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        } else {
          // Show error message for invalid credentials
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid username or password')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  Future<void> _storeDetailsInPrefs(bool isUser, bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    prefs.setString('Email', emailController.text.toString());
    prefs.setString('Password', passwordController.text.toString());
    prefs.setBool('isUser', isUser); // Store whether the user is a user
    prefs.setBool('isAdmin', isAdmin); // Store whether the user is an admin
  }
  Future<bool> fetchUserCredentials(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/fetchUserCredentials'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> fetchMentorCredentials(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/fetchMentorCredentials'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<List<dynamic>>> fetchUserData(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/fetchUserData'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<List<dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<List<dynamic>>> fetchMentorData(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/fetchMentorData'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<List<dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  bool _validatePassword(String password) {
    // Regular expression to check if password contains at least one letter, one number, and one special character
    final RegExp regex =
    RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return regex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formkey,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 120),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: emailController,
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
                      contentPadding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(9.0)),
                      ),
                    ),
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
                      contentPadding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(9.0)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtility.screenHeight * 0.05),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoggingIn
                        ? null
                        : () {
                        _login();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(
                        ScreenUtility.screenWidth * 0.8,
                        ScreenUtility.screenHeight * 0.07,
                      ), // Increase button size
                    ),
                    child: _isLoggingIn
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      'Log In',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'signupScreen');
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Want to be a partner? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'MentorDetailsRegister');
                      },
                      child: const Text('Click here'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
