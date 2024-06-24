import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:saloon/Get%20Started/get_started.dart';
import 'package:saloon/LoginScreens/login_screen.dart';
import 'package:saloon/LoginScreens/otp_screen.dart';
import 'package:saloon/splash_screen.dart';
import 'package:saloon/LoginScreens/phone_login_screen.dart';
import 'Partner_Pages/partner_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context) => SplashScreen(),
      'loginScreen':(context) => LoginScreen(),
      'getStarted':(context)=>const GetStarted(),
      'partner-page':(context)=> PartnerPage(),
      'phoneLogin': (context) => const Phonelogin(),
      'otp': (context) => const OtpScreen(),
    },
    theme: ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: const Color.fromRGBO(18, 26, 18, 1),
      scaffoldBackgroundColor: const Color.fromRGBO(255, 255, 255, 1),
    ),
  )
  );
}