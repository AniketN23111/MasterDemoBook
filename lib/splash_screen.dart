import 'dart:async';
import 'package:flutter/material.dart';
import 'package:passionHub/HomeScreen/my_home_page.dart';
import 'package:passionHub/LoginScreens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  var isLogin = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    _timer = Timer(
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
          builder: (context) => const MyHomePage(), // Use user!
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, 'loginScreen');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xD80CFFD2), Color(0xD8317766)],
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    "BlackOX PASSION HUB",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36.0,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Connecting Agro Experts with Farmers",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 30.0,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
