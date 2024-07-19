import 'package:flutter/material.dart';
import 'package:saloon/LoginScreens/login_screen.dart';
import 'package:saloon/LoginScreens/sign_up_screen.dart';
import 'package:saloon/MentorRegister/mentor_details_register.dart';
import 'package:saloon/splash_screen.dart';
import 'Constants/screen_utility.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      builder: (context, child) {
        ScreenUtility.init(context);
        return child!;
      },
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SplashScreen(),
        'loginScreen':(context) => const LoginScreen(),
        'signupScreen':(context)=> const SignUpScreen(),
        'MentorDetailsRegister':(context)=> const MentorDetailsRegister(),
      },
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: const Color.fromRGBO(18, 26, 18, 1),
        scaffoldBackgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      ),
    );
  }
}