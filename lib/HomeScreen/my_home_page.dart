import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saloon/HomeScreen/search_page.dart';
import 'package:saloon/LoginScreens/login_screen.dart';
import 'package:saloon/MasterSeparateDetails/separate_mentor_details.dart';
import 'package:saloon/Models/mentor_details.dart';
import 'package:saloon/Models/mentor_service.dart';
import 'package:saloon/Models/progress_tracking.dart';
import 'package:saloon/Models/user_details.dart';
import 'package:saloon/ProgressTracking/progress_tracking_details.dart';
import 'package:saloon/Services/database_service.dart';
import 'package:saloon/UserDetailsPage/user_details_page.dart';
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
  List<AppointmentsDetails> appointmentsList = [];
  List<UserDetails> userDetailsList = [];
  Map<int, int> usersPerMentor = {}; // Map to store user count per mentor
  bool isLoading = true;
  bool isUser = true;

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
    await _countUsersPerMentor(); // Count users per mentor
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
      MentorDetails? details = await dbService.getMentorByEmailDetails(
          email, password);
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
      // Sort appointments by date in decreasing order
      appointments.sort((a, b) => a.date.compareTo(b.date)); // Compare DateTime directly
      setState(() {
        appointmentsList = appointments;
      });
    } else if (!isUser && mentorDetails != null) {
      List<AppointmentsDetails> appointments = await dbService.getMentorAppointmentsAllDetails(mentorDetails!.advisorID);
      // Sort appointments by date in decreasing order
      appointments.sort((a, b) => b.date.compareTo(a.date)); // Compare DateTime directly
      // Fetch user details for each appointment
      List<UserDetails> users = [];
      Set<int> displayedUserIds = {}; // Track displayed user IDs
      for (var appointment in appointments) {
        UserDetails? user = await dbService.getUserDetailsById(appointment.userID);
        if (user != null && !displayedUserIds.contains(user.userID)) {
          users.add(user);
          displayedUserIds.add(user.userID); // Add user ID to the set
        }
      }
      setState(() {
        appointmentsList = appointments;
        userDetailsList = users; // Store the list of user details
      });
    }
  }


  Future<void> _countUsersPerMentor() async {
    // Count users per mentor based on appointmentsList
    usersPerMentor.clear();
    for (var appointment in appointmentsList) {
      if (usersPerMentor.containsKey(appointment.advisorID)) {
        usersPerMentor[appointment.advisorID] =
            usersPerMentor[appointment.advisorID]! + 1;
      } else {
        usersPerMentor[appointment.advisorID] = 1;
      }
    }
  }

  void _showProgressTrackingDetails(ProgressTracking progressTracking) {
    Navigator.pop(context); // Close the loading dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProgressTrackingDetailsPage(progressTracking: progressTracking),
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
    ProgressTracking? progressTracking = await dbService
        .getProgressTrackingByAppointmentId(appointmentId);
    if (progressTracking != null) {
      _showProgressTrackingDetails(progressTracking);
    } else {
      if (!mounted) return;
      Navigator.pop(
          context); // Close the loading dialog if no progress tracking found
      if (kDebugMode) {
        print("No progress tracking found for this appointment");
      }
    }
  }
  void _navigateToUserDetails(UserDetails user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsPage( userId:  user.userID, advisorId:mentorDetails!.advisorID),
      ),
    );
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
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.blue,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Hello, $userFirstName!',
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
                              mentorDetails.imageURL,
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
            if (!isUser && userDetailsList.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Users who have booked appointments:',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userDetailsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = userDetailsList[index];
                      return GestureDetector(
                        onTap: () {
                          _navigateToUserDetails(user); // Function to navigate to user details
                        },
                        child: ListTile(
                          title: Text(user.name),
                          subtitle: Text('Email: ${user.email}'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Appointments:',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
            if (appointmentsList.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appointmentsList.length,
                itemBuilder: (BuildContext context, int index) {
                  final appointment = appointmentsList[index];
                  final user = index < userDetailsList.length ? userDetailsList[index] : null;
                  final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse('${appointment.date}'));
                  return ListTile(
                    title: Text(formattedDate), // Display formatted date
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Time: ${appointment.time}'),
                        if (isUser)
                          Text('Mentor: ${mentorDetailsList.firstWhere((mentor) => mentor.advisorID == appointment.advisorID).name}'),
                      ],
                    ),
                    onTap: () => _onAppointmentTap(appointment.appointmentID),
                  );
                },
              ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                'Welcome, $userFirstName!',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            if (isUser)
              ListTile(
                title: const Text('Profile'),
                onTap: () {
                  // Navigate to user profile screen
                },
              ),
            if (!isUser)
              ListTile(
                title: const Text('Profile'),
                onTap: () {
                  // Navigate to mentor profile screen
                },
              ),
            ListTile(
              title: const Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
    );
  }
}

