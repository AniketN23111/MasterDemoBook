import 'dart:async';
import 'package:flutter/foundation.dart';
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
  MentorDetails? mentorDetails;
  List<MentorService> masterServiceList = [];
  List<AppointmentsDetails> appointmentsList = []; // Generalize the appointments list
  bool isLoading = true; // Add a boolean variable to track loading state
  bool isUser = true; // Add a boolean variable to track user type

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getDetailsInPrefs();
    await _fetchMentorDetails();
    await _fetchMasterService();
    await _fetchAppointments(); // Fetch appointments for both users and mentors
    setState(() {
      isLoading = false; // Set loading to false when data fetching is complete
    });
  }

  Future<void> _getDetailsInPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('Email')!;
    userPass = prefs.getString('Password')!;
    isUser = prefs.getBool('isUser') ?? true; // Get the user type flag
    await _fetchUserDetails(userEmail, userPass);
  }

  Future<void> _fetchUserDetails(String email, String password) async {
    DatabaseService dbService = DatabaseService();
    if (isUser) {
      UserDetails? details = await dbService.getUserDetails(email, password);
      if (details != null) {
        setState(() {
          userDetails = details;
          userFirstName = userDetails!.name;
        });
      } else {
        if (kDebugMode) {
          print('User not found');
        }
      }
    } else {
      MentorDetails? details = await dbService.getMentorByEmailDetails(email, password);
      if (details != null) {
        setState(() {
          mentorDetails = details;
          userFirstName = mentorDetails!.name;
        });
      } else {
        if (kDebugMode) {
          print('Mentor not found');
        }
      }
    }
  }

  Future<void> _fetchMentorDetails() async {
    DatabaseService dbService = DatabaseService();
    List<MentorDetails> details = await dbService.getMentorDetails();
    setState(() {
      mentorDetailsList = details;
    });
  }

  Future<void> _fetchMasterService() async {
    DatabaseService dbService = DatabaseService();
    List<MentorService> details = await dbService.getMentorServices();
    setState(() {
      masterServiceList = details;
    });
  }

  Future<void> _fetchAppointments() async {
    DatabaseService dbService = DatabaseService();
    if (isUser && userDetails != null) {
      List<AppointmentsDetails> appointments = await dbService.getUserAppointmentsAllDetails(userDetails!.userID);
      setState(() {
        appointmentsList = appointments;
      });
    } else if (!isUser && mentorDetails != null) {
      List<AppointmentsDetails> appointments = await dbService.getMentorAppointmentsAllDetails(mentorDetails!.advisorID);
      setState(() {
        appointmentsList = appointments;
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
      if (!mounted) return;
      Navigator.pop(context); // Close the loading dialog if no progress tracking found
      if (kDebugMode) {
        print("No progress tracking found for this appointment");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading // Show CircularProgressIndicator if isLoading is true
          ? const Center(
        child: CircularProgressIndicator(color: Colors.blue,),
      )
          : SingleChildScrollView(
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
                  if (isUser)
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
            if (isUser)
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
            if (isUser)
              const Divider(), // Divider for separating appointments
            if (isUser)
              const SizedBox(height: 16.0),
            // Display Appointments
            if (appointmentsList.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      isUser ? 'Your Appointments:' : 'Mentor Appointments:',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appointmentsList.length,
                    itemBuilder: (context, index) {
                      final appointment = appointmentsList[index];
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
            if (!isUser && mentorDetails != null) // Only show for mentors
              Column(
                children: [
                  const SizedBox(height: 16.0),
                  const Text(
                    'Mentor Details:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  ListTile(
                    title: Text('Mentor ID: ${mentorDetails!.advisorID}'),
                    subtitle: Text('Mentor Name: ${mentorDetails!.name}'),
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
