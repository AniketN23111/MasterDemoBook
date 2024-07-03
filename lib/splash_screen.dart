import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:saloon/HomeScreen/home_page.dart';

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
