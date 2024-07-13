import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saloon/HomeScreen/search_page.dart';
import 'package:saloon/LoginScreens/login_screen.dart';
import 'package:saloon/MasterSeparateDetails/separate_mentor_details.dart';
import 'package:saloon/Models/mentor_service.dart';
import 'package:saloon/Models/progress_tracking.dart';
import 'package:saloon/Models/user_details.dart';
import 'package:saloon/ProgressTracking/progress_tracking_details.dart';
import 'package:saloon/Services/database_service.dart';
import 'package:saloon/Models/mentor_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saloon/Models/appointments_details.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userFirstName = '';
  String userEmail = '';
  String userPass = '';
  List<MentorDetails> mentorDetailsList = [];
  UserDetails? userDetails;
  List<MentorService> masterServiceList = [];
  List<AppointmentsDetails> userAppointments = [];

  @override
  void initState() {
    super.initState();
    _fetchMentorDetails();
    _fetchMasterService();
    _getDetailsInPrefs();
    _fetchUserAppointments();
  }

  Future<void> _getDetailsInPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('Email')!;
    userPass = prefs.getString('Password')!;
    _fetchUserDetails(userEmail, userPass);
  }

  void _fetchUserDetails(String email, String password) async {
    DatabaseService dbService = DatabaseService();
    UserDetails? details = await dbService.getUserDetails(email, password);
    if (details != null) {
      setState(() {
        userDetails = details;
        userFirstName = userDetails!.name;
      });
      _fetchUserAppointments();
    } else {
      print('User not found');
    }
  }

  void _fetchMentorDetails() async {
    DatabaseService dbService = DatabaseService();
    List<MentorDetails> details = await dbService.getMentorDetails();
    setState(() {
      mentorDetailsList = details;
    });
  }

  void _fetchMasterService() async {
    DatabaseService dbService = DatabaseService();
    List<MentorService> details = await dbService.getMentorServices();
    setState(() {
      masterServiceList = details;
    });
  }

  void _fetchUserAppointments() async {
    if (userDetails != null) {
      DatabaseService dbService = DatabaseService();
      List<AppointmentsDetails> appointments = await dbService.getUserAppointmentsAllDetails(userDetails!.userID);
      setState(() {
        userAppointments = appointments;
      });
    }
  }

  void _showProgressTrackingDetails(ProgressTracking progressTracking) {
    Navigator.pop(context); // Close the loading dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressTrackingDetailsPage(progressTracking: progressTracking),
      ),
    );
  }

  void _onAppointmentTap(int appointmentId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.blue,),
        );
      },
    );

    DatabaseService dbService = DatabaseService();
    ProgressTracking? progressTracking = await dbService.getProgressTrackingByAppointmentId(appointmentId);
    if (progressTracking != null) {
      _showProgressTrackingDetails(progressTracking);
    } else {
      Navigator.pop(context); // Close the loading dialog if no progress tracking found
      print("No progress tracking found for this appointment");
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.blue, // Blue container
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Hello, $userFirstName!', // Display the user's first name
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for a Service',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              // Container for the list view of images
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mentorDetailsList.length,
                itemBuilder: (BuildContext context, int index) {
                  final mentorDetails = mentorDetailsList[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              mentorDetails: mentorDetails,
                              masterServices: masterServiceList,
                              userDetails: userDetails,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Image.network(
                            mentorDetails.imageURL, // Replace with your image URLs
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Text(mentorDetails.name),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            const Divider(), // Divider for separating appointments
            const SizedBox(height: 16.0),
            // Display User Appointments
            if (userAppointments.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Appointments:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = userAppointments[index];
                      // Format date to show only date part
                      String formattedDate = '${appointment.date.day}-${appointment.date.month}-${appointment.date.year}';
                      return ListTile(
                        title: Text('Date: $formattedDate'),
                        leading: Text('${index + 1}.'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Main Service: ${appointment.mainService}'),
                            Text('Sub Service: ${appointment.subService}'),
                            Text('Time: ${appointment.time}'),
                          ],
                        ),
                        onTap: () {
                          _onAppointmentTap(appointment.appointmentID);
                        },
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: logout,
        tooltip: 'Logout',
        child: const Icon(Icons.logout),
      ),
    );
  }
}
