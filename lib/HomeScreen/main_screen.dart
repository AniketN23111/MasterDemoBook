import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:passionHub/HomeScreen/my_home_page.dart';
import 'package:passionHub/HomeScreen/profile_page.dart';
import 'package:http/http.dart' as http;
import 'package:passionHub/LoginScreens/login_screen.dart';
import 'package:passionHub/Models/mentor_details.dart';
import 'package:passionHub/Models/user_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String userFirstName = '';
  String userEmail = '';
  String userPass = '';
  int _selectedIndex = 0;
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
  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
  final List<Widget> _pages = [
    const MyHomePage(),
    const ProfilePage(),
  ];

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/Logo.png', // Add your company logo URL here
                        width: 90,  // Adjust the size of the logo
                        height: 90,
                      ),
                      const SizedBox(width: 20),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                            isUser
                                ? userDetails?.imageURL ?? '' // If it's a user, show user image
                                : mentorDetails?.imageURL ?? '' // If it's a mentor, show mentor image
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userFirstName,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () => _onDrawerItemTapped(0),
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () => _onDrawerItemTapped(1),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap:  logout,
            ),
            // Add other drawer items here
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}