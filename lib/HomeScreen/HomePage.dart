import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saloon/HomeScreen/MyHomePage.dart';
import 'package:saloon/HomeScreen/ProfilePage.dart'; // Import the ProfilePage
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    // Home Tab
    MyHomePage(),
    // Appointments Tab
    Center(
      child: Text('Appointments Content'),
    ),
    // Profile Tab
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex], // Display the selected tab content
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.grey.shade200, // Background color of the navigation bar
        buttonBackgroundColor: Colors.grey.shade200, // Background color of the active tab
        height: 70,
        animationDuration: Duration(milliseconds: 300),// Height of the navigation bar
        index: _currentIndex,
        items: <Widget>[
          SvgPicture.asset('assets/icons/home-angle-svgrepo-com.svg', width: 30, height: 30),
          SvgPicture.asset('assets/icons/calendar-svgrepo-com.svg', width: 30, height: 30),
          SvgPicture.asset('assets/icons/profile-svgrepo-com (1).svg', width: 30, height: 30),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}