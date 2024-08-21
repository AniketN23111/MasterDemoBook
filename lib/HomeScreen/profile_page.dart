import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:passionHub/Models/mentor_details.dart';
import 'package:passionHub/Models/user_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userFirstName = '';
  String userEmail = '';
  String userPass = '';
  bool isUser = false;
  bool isMentor = false;
  UserDetails? userDetails;
  MentorDetails? mentorDetails;

  final String baseUrl = 'https://mentor.passionit.com/mentor-api';

  @override
  void initState() {
    super.initState();
    _getDetailsInPrefs();
  }

  Future<void> _getDetailsInPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('Email')!;
    userPass = prefs.getString('Password')!;
    isUser = prefs.getBool('isUser') ?? true; // Get the user type flag
    await _fetchUserDetails(userEmail, userPass);
  }

  Future<void> _fetchUserDetails(String email, String password) async {
    final String endpoint = isUser ? '/user/login' : '/mentor/login';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (isUser) {
          // Assuming `UserDetails` is a model class with a `fromJson` method
          UserDetails details = UserDetails.fromJson(data);
          setState(() {
            userDetails = details;
            userFirstName = userDetails!.name;
          });
        } else {
          // Assuming `MentorDetails` is a model class with a `fromJson` method
          MentorDetails details = MentorDetails.fromJson(data);
          setState(() {
            isMentor = true;
            mentorDetails = details;
            userFirstName = 'Mentor - ${mentorDetails!.name}';
          });
        }
      } else {
        // Handle error response
        if (kDebugMode) {
          print('Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Handle exception
      if (kDebugMode) {
        print('Exception: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(userDetails!.name),
        ],
      ),
    );
  }
}
