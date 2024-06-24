import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:saloon/HomeScreen/HomePage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  var isLogin = false;
  var auth = FirebaseAuth.instance;
  late User? user; // Change User to User? to handle null when user is not logged in

  checkIfLogin() async {
    auth.authStateChanges().listen((User? currentUser) {
      if (currentUser != null && mounted) {
        setState(() {
          isLogin = true;
          user = currentUser; // Assign the logged-in user
        });
      }
    });
  }

  void initState() {
    super.initState();
    startTimer();
    checkIfLogin();
  }

  startTimer() {
    var duration = Duration(seconds: 2);
    return Timer(duration, route);
  }

  route() {
    if (isLogin == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(user: user!), // Use user!
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, 'getStarted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.black,
          child: Column(
            children: [
              SizedBox(height: 300),
              Center(
                child: Image.asset('assets/salon-s.gif'),
              ),
              SizedBox(height: 20),
              DefaultTextStyle(
                style: const TextStyle(fontSize: 40.0, fontFamily: 'Horizon'),
                child: AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText('Salon'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
