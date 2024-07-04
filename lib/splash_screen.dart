import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:saloon/HomeScreen/home_page.dart';
import 'package:saloon/HomeScreen/my_home_page.dart';
import 'package:saloon/LoginScreens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  var isLogin = false;

  checkIfLogin() async {
  }

  void initState() {
    super.initState();
    startTimer();
    checkIfLogin();
    _navigateToNextScreen();
  }


  Future<void> _navigateToNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    Timer(
      const Duration(seconds: 3),
          () {
        if (isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
    );
  }

  startTimer() {
    var duration = const Duration(seconds: 2);
    return Timer(duration, route);
  }

  route() {
    if (isLogin == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(), // Use user!
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, 'loginScreen');
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
              const SizedBox(height: 300),
              Center(
                child: Image.asset('assets/salon-s.gif'),
              ),
              const SizedBox(height: 20),
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
