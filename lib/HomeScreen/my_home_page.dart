import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:passionHub/GoalDetailsPage/goal_details_page.dart';
import 'package:passionHub/HomeScreen/search_page.dart';
import 'package:passionHub/MasterSeparateDetails/separate_mentor_details.dart';
import 'package:passionHub/Models/mentor_details.dart';
import 'package:passionHub/Models/mentor_service.dart';
import 'package:passionHub/Models/progress_tracking.dart';
import 'package:passionHub/Models/user_details.dart';
import 'package:passionHub/ProgressTracking/progress_tracking_details.dart';
import 'package:passionHub/Services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passionHub/Models/appointments_details.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
  List<AppointmentsDetails> closedAppointmentsList = [];
  List<UserDetails> userDetailsList = [];
  Map<int, int> usersPerMentor = {}; // Map to store user count per mentor
  bool isLoading = true;
  bool isUser = false;
  bool isMentor = false;

  final String baseUrl = 'https://mentor.passionit.com/mentor-api';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _fetchUserDetails(String email, String password) async {
    final String endpoint = isUser ? '/user/login' : '/mentor/login';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (isUser) {
          // Assuming `UserDetails` is a model class with a `fromJson` method
          UserDetails details = UserDetails.fromJson(data);
          setState(() {
            userDetails = details;
            userFirstName = userDetails!.name;
          });
        } else {
          // Assuming `MentorDetails` is a model class with a `fromJson` method
          MentorDetails details = MentorDetails.fromJson(data);
          setState(() {
            isMentor = true;
            mentorDetails = details;
            userFirstName = 'Mentor - ${mentorDetails!.name}';
          });

          // Fetch additional mentor details if needed
          _fetchMentorDetails(); // Fetch other mentor details
        }
      } else {
        // Handle error response
        if (kDebugMode) {
          print('Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Handle exception
      if (kDebugMode) {
        print('Exception: $e');
      }
    }
  }

  Future<void> _fetchMentorDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mentor/details'), // Adjust endpoint if needed
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Assuming `MentorDetails` is a model class with a `fromJson` method
        List<MentorDetails> details = data.map((json) =>
            MentorDetails.fromJson(json)).toList();
        setState(() {
          mentorDetailsList = details;
        });
      } else {
        // Handle error response
        if (kDebugMode) {
          print('Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Handle exception
      if (kDebugMode) {
        print('Exception: $e');
      }
    }
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

  Future<void> _fetchMasterService() async {
    DatabaseService dbService = DatabaseService();
    List<MentorService> details = await dbService.getMentorServices();
    setState(() {
      masterServiceList = details;
    });
  }

  Future<void> _fetchAppointments() async {
    DatabaseService dbService = DatabaseService();
    DateTime now = DateTime.now();
    if (isUser && userDetails != null) {
      try {
        List<AppointmentsDetails> appointments = await dbService
            .getUserAppointmentsAllDetails(userDetails!.userID);
        setState(() {
          appointmentsList =
          appointments.where((appointment) => appointment.date.isAfter(now))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
          closedAppointmentsList =
          appointments.where((appointment) => appointment.date.isBefore(now))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching user appointments: $e');
        }
      }
    } else if (!isUser && mentorDetails != null) {
      try {
        List<AppointmentsDetails> appointments = await dbService
            .getMentorAppointmentsAllDetails(mentorDetails!.advisorID);
        List<UserDetails> users = [];
        Set<int> displayedUserIds = {}; // Track displayed user IDs

        for (var appointment in appointments) {
          UserDetails? user = await dbService.getUserDetailsById(
              appointment.userID);
          if (user != null && !displayedUserIds.contains(user.userID)) {
            users.add(user);
            displayedUserIds.add(user.userID); // Add user ID to the set
          }
        }
        setState(() {
          appointmentsList =
          appointments.where((appointment) => appointment.date.isAfter(now))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
          closedAppointmentsList =
          appointments.where((appointment) => appointment.date.isBefore(now))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
          userDetailsList = users; // Store the list of user details
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching mentor appointments: $e');
        }
      }
    }
  }

  Future<void> _countUsersPerMentor() async {
    // Count users per mentor based on appointmentsList
    usersPerMentor.clear();
    for (var appointment in appointmentsList) {
      if (usersPerMentor.containsKey(appointment.advisorID)) {
        usersPerMentor[appointment.advisorID] =
            usersPerMentor[appointment.advisorID]! + 1;
      }
      else {
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
            ProgressTrackingDetailsPage(
                progressTracking: progressTracking, isMentor: isMentor),
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
        builder: (context) =>
            GoalDetailsPage(
                userId: user.userID, advisorId: mentorDetails!.advisorID),
      ),
    );
  }

  Future<ProgressTracking?> _fetchProgressTrackingByAppointmentId(
      int appointmentId) async {
    DatabaseService dbService = DatabaseService();
    try {
      return await dbService.getProgressTrackingByAppointmentId(appointmentId);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching progress tracking: $e');
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Center(
                        child: Text(
                          'Hello, $userFirstName',
                          style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  if (isUser)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search for a Service',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
                              builder: (context) =>
                                  DetailPage(
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
            if (isMentor && userDetailsList.isNotEmpty)
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
                      return Card(
                        child: ListTile(
                          title: Text('Mentee: ${user.name}'),
                          subtitle: Text('Email: ${user.email}'),
                          onTap: () {
                            _navigateToUserDetails(
                                user); // Function to navigate to user details
                          },
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
            if(isUser)
              if (appointmentsList.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildAppointmentsGroupedByMentor(
                    appointmentsList,
                    'Mentor: ',
                  ),
                ),
            const SizedBox(height: 16.0),
            if(isUser)
              if (closedAppointmentsList.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Center(
                        child: Text(
                          'Closed Appointments:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildAppointmentsGroupedByMentor(
                        closedAppointmentsList,
                        'Closed ',
                      ),
                    ),
                  ],
                ),
            if(isMentor)
              if (appointmentsList.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildAppointmentsGroupedByUser(
                    appointmentsList,
                    '',
                  ),
                ),
            const SizedBox(height: 16.0),
            if(isMentor)
              if (closedAppointmentsList.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Center(
                        child: Text(
                          'Closed Appointments:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildAppointmentsGroupedByUser(
                        closedAppointmentsList,
                        '',
                      ),
                    ),
                  ],
                ),
          ],
        ),

      ),
    );
  }

  List<Widget> _buildAppointmentsGroupedByMentor(
      List<AppointmentsDetails> appointments, String titlePrefix) {
    List<Widget> widgets = [];
    Map<int, List<AppointmentsDetails>> groupedAppointments = {};
    Map<int, bool> isExpanded = {};

    // Group appointments by mentorID
    for (var appointment in appointments) {
      if (!groupedAppointments.containsKey(appointment.advisorID)) {
        groupedAppointments[appointment.advisorID] = [];
      }
      groupedAppointments[appointment.advisorID]!.add(appointment);
    }

    // Create widgets for each mentor and their appointments
    groupedAppointments.forEach((mentorID, appointments) {
      var mentorIndex = mentorDetailsList.indexWhere((mentor) =>
      mentor.advisorID == mentorID);
      if (mentorIndex != -1) {
        var mentor = mentorDetailsList[mentorIndex];
        bool expanded = isExpanded[mentorID] ?? false;
        widgets.add(
          ExpansionTile(
            title: Text(
              '$titlePrefix${mentor.name}',
              style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            trailing: Image.network(mentor.imageURL),
            initiallyExpanded: expanded,
            onExpansionChanged: (bool expanded) {
              setState(() {
                isExpanded[mentorID] = expanded;
              });
            },
            children: appointments.map((appointment) {
              return FutureBuilder<ProgressTracking?>(
                future: _fetchProgressTrackingByAppointmentId(
                    appointment.appointmentID),
                builder: (context, snapshot) {
                  Icon trailingIcon;
                  Color trailingColor = Colors.grey;

                  // Determine the appropriate icon and color based on the progress status
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text(
                          'Appointment on ${DateFormat('yyyy-MM-dd').format(
                              appointment.date)}'),
                      subtitle: const Text('Loading progress tracking...'),
                    );
                  } else if (snapshot.hasError) {
                    return ListTile(
                      title: Text(
                          'Appointment on ${DateFormat('yyyy-MM-dd').format(
                              appointment.date)}'),
                      subtitle: const Text('Error loading progress tracking'),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return ListTile(
                      title: Text(
                          'Appointment on ${DateFormat('yyyy-MM-dd').format(
                              appointment.date)}'),
                      subtitle: const Text('No progress tracking available'),
                    );
                  } else {
                    ProgressTracking? progressTracking = snapshot.data;

                    if (progressTracking != null) {
                      switch (progressTracking.progressStatus) {
                        case 'Open':
                          trailingIcon = const Icon(Icons.check_circle, color: Colors.blue);
                          trailingColor = Colors.green;
                          break;
                        case 'Closed':
                          trailingIcon = const Icon(Icons.error, color: Colors.red);
                          trailingColor = Colors.red;
                          break;
                        case 'In Progress':
                          trailingIcon = const Icon(Icons.hourglass_empty, color: Colors.orange);
                          trailingColor = Colors.orange;
                          break;
                        case 'Hold':
                          trailingIcon = const Icon(Icons.pause_circle_filled, color: Colors.grey);
                          trailingColor = Colors.grey;
                          break;
                        default:
                          trailingIcon = const Icon(Icons.help, color: Colors.grey);
                          trailingColor = Colors.grey;
                          break;
                      }
                    } else {
                      trailingIcon = const Icon(Icons.help, color: Colors.grey);
                      trailingColor = Colors.grey;
                    }

                    return ListTile(
                      onTap: () => _onAppointmentTap(appointment.appointmentID),
                      title: Text(
                          'Appointment on ${DateFormat('yyyy-MM-dd').format(
                              appointment.date)}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Main Service: ${appointment.mainService}'),
                          Text('Sub Service: ${appointment.subService}'),
                          Text('Time: ${appointment.time}'),
                        ],
                      ),
                      trailing: trailingIcon,
                    );
                  }
                },
              );
            }).toList(),
          ),
        );
      }
    });

    return widgets;
  }
  List<Widget> _buildAppointmentsGroupedByUser(
      List<AppointmentsDetails> appointments, String titlePrefix) {
    List<Widget> widgets = [];
    Map<int, List<AppointmentsDetails>> groupedAppointments = {};
    Map<int, bool> isExpanded = {};

    // Group appointments by userID
    for (var appointment in appointments) {
      if (!groupedAppointments.containsKey(appointment.userID)) {
        groupedAppointments[appointment.userID] = [];
      }
      groupedAppointments[appointment.userID]!.add(appointment);
    }

    // Create widgets for each user and their appointments
    groupedAppointments.forEach((userID, appointments) {
      var userIndex = userDetailsList.indexWhere((user) => user.userID == userID);
      if (userIndex != -1) {
        var user = userDetailsList[userIndex];
        bool expanded = isExpanded[userID] ?? false;
        widgets.add(
          ExpansionTile(
            title: Text(
              '$titlePrefix${user.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            leading: Image.network(user.imageURL),
            initiallyExpanded: expanded,
            onExpansionChanged: (bool expanded) {
              setState(() {
                isExpanded[userID] = expanded;
              });
            },
            children: appointments.map((appointment) {
              return FutureBuilder<ProgressTracking?>(
                future: _fetchProgressTrackingByAppointmentId(appointment.appointmentID),
                builder: (context, snapshot) {
                  Icon trailingIcon;
                  Color trailingColor = Colors.grey;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Appointment on ${DateFormat('yyyy-MM-dd').format(appointment.date)}'),
                      subtitle: const Text('Loading progress tracking...'),
                    );
                  } else if (snapshot.hasError) {
                    return ListTile(
                      title: Text('Appointment on ${DateFormat('yyyy-MM-dd').format(appointment.date)}'),
                      subtitle: const Text('Error loading progress tracking'),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return ListTile(
                      title: Text('Appointment on ${DateFormat('yyyy-MM-dd').format(appointment.date)}'),
                      subtitle: const Text('No progress tracking available'),
                    );
                  } else {
                    ProgressTracking? progressTracking = snapshot.data;

                    if (progressTracking != null) {
                      switch (progressTracking.progressStatus) {
                        case 'Open':
                          trailingIcon = const Icon(Icons.check_circle, color: Colors.blue);
                          trailingColor = Colors.green;
                          break;
                        case 'Closed':
                          trailingIcon = const Icon(Icons.error, color: Colors.red);
                          trailingColor = Colors.red;
                          break;
                        case 'In Progress':
                          trailingIcon = const Icon(Icons.hourglass_empty, color: Colors.orange);
                          trailingColor = Colors.orange;
                          break;
                        case 'Hold':
                          trailingIcon = const Icon(Icons.pause_circle_filled, color: Colors.grey);
                          trailingColor = Colors.grey;
                          break;
                        default:
                          trailingIcon = const Icon(Icons.help, color: Colors.grey);
                          trailingColor = Colors.grey;
                          break;
                      }
                    } else {
                      trailingIcon = const Icon(Icons.help, color: Colors.grey);
                      trailingColor = Colors.grey;
                    }

                    return ListTile(
                      onTap: () => _onAppointmentTap(appointment.appointmentID),
                      title: Text('Appointment on ${DateFormat('yyyy-MM-dd').format(appointment.date)}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Main Service: ${appointment.mainService}'),
                          Text('Sub Service: ${appointment.subService}'),
                          Text('Time: ${appointment.time}'),
                        ],
                      ),
                      trailing: trailingIcon,
                    );
                  }
                },
              );
            }).toList(),
          ),
        );
      }
    });
    return widgets;
  }
}