import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:passionHub/Models/appointments_details.dart';
import 'package:passionHub/Models/admin_service.dart';
import 'package:passionHub/Models/mentor_service.dart';
import 'package:passionHub/Models/program_initializer.dart';
import 'package:passionHub/Models/progress_tracking.dart';
import 'package:passionHub/Models/user_details.dart';
import 'package:http/http.dart' as http;

class DatabaseService {
  final String baseUrl = 'http://localhost:3000';

  Future<List<AdminService>> getAdminService() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/services'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => AdminService.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load mentor services');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<void> registerService(
      String service, String subService, String imageUrl) async {
    final response = await http.post(
      Uri.parse('$baseUrl/registerService'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'service': service,
        'subService': subService,
        'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode == 200) {
      // Service registered successfully
      print('Service registered');
    } else {
      // Error registering service
      print('Error: ${response.body}');
    }
  }

// Function to register a program initializer
  Future<void> registerProgramInitializer(
      String programName,
      String programDescription,
      String organizationName,
      String imageUrl,
      String coordinatorName,
      String coordinatorEmail,
      String coordinatorNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/registerProgramInitializer'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'programName': programName,
        'programDescription': programDescription,
        'organizationName': organizationName,
        'imageUrl': imageUrl,
        'coordinatorName': coordinatorName,
        'coordinatorEmail': coordinatorEmail,
        'coordinatorNumber': coordinatorNumber,
      }),
    );

    if (response.statusCode == 200) {
      // Program initializer registered successfully
      print('Program initializer registered');
    } else {
      // Error registering program initializer
      print('Error: ${response.body}');
    }
  }

  Future<List<MentorService>> getMentorServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mentor/services'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => MentorService.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load mentor services');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<void> insertMentorMeeting({
    required int userId,
    required int advisorId,
    required String title,
    required DateTime meetingDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String location,
    required String eventDetails,
    required String description,
    required String meetingLink,
    required int appointmentId,
  }) async {
    final url = '$baseUrl/insert-mentor-meeting';

    final body = jsonEncode({
      'userId': userId,
      'advisorId': advisorId,
      'title': title,
      'meetingDate': meetingDate.toIso8601String(),
      'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00',
      'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00',
      'location': location,
      'eventDetails': eventDetails,
      'description': description,
      'meetingLink': meetingLink,
      'appointmentId': appointmentId,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Mentor meeting inserted successfully');
      } else {
        print('Failed to insert mentor meeting: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String?> getUserName(int userId) async {
    final url = '$baseUrl/getUserName/$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['user_name'] as String?;
      } else {
        throw Exception('Failed to load user name');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Get advisor name by advisorId
  Future<String?> getAdvisorName(int advisorId) async {
    final url = '$baseUrl/getAdvisorName/$advisorId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['advisor_name'] as String?;
      } else {
        throw Exception('Failed to load advisor name');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> insertProgressTracking({
    required int advisorId,
    required String advisorName,
    required int userId,
    required String userName,
    required DateTime date,
    required String goalType,
    required String goal,
    required String actionSteps,
    required String timeline,
    required DateTime progressDate,
    required String progressMade,
    required DateTime effectivenessDate,
    required String outcome,
    required String nextSteps,
    required DateTime meetingDate,
    required String agenda,
    required String additionalNotes,
    required int appointmentId,
  }) async {
    final url = '$baseUrl/insert-progress-tracking';

    final body = jsonEncode({
      'advisorId': advisorId,
      'advisorName': advisorName,
      'userId': userId,
      'userName': userName,
      'date': date.toIso8601String(),
      'goalType': goalType,
      'goal': goal,
      'actionSteps': actionSteps,
      'timeline': timeline,
      'progressDate': progressDate.toIso8601String(),
      'progressMade': progressMade,
      'effectivenessDate': effectivenessDate.toIso8601String(),
      'outcome': outcome,
      'nextSteps': nextSteps,
      'meetingDate': meetingDate.toIso8601String(),
      'agenda': agenda,
      'additionalNotes': additionalNotes,
      'appointmentId': appointmentId,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Progress tracking details inserted successfully');
      } else {
        print('Failed to insert progress tracking details: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<int?> getAppointmentID(DateTime date, String time, int advisorID, String mainService, String subService, int userID) async {
    // Construct the URL with query parameters
    final url = Uri.parse(
        '$baseUrl/get-appointment-id?date=${date
            .toIso8601String()}&time=$time&advisorId=$advisorID&mainService=$mainService&subService=$subService&userId=$userID'
    );

    try {
      // Make the GET request
      final response = await http.get(url);

      // Check the response status
      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = jsonDecode(response.body);
        return data['appointment_id'] as int?;
      } else if (response.statusCode == 404) {
        // Handle not found case
        return null;
      } else {
        // Handle other errors
        throw Exception('Failed to retrieve appointment ID');
      }
    } catch (e) {
      // Handle exceptions
      print('Error: $e');
      return null;
    }
  }
  Future<ProgressTracking?> getProgressTrackingByAppointmentId(
      int appointmentID) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/progress-tracking/$appointmentID'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return ProgressTracking.fromJson(data);
      } else if (response.statusCode == 404) {
        print('Progress tracking not found');
        return null;
      } else {
        throw Exception('Failed to load progress tracking');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<String>> getDistinctGoalTypes(int userId, int advisorId) async {
    final url = Uri.parse('$baseUrl/getDistinctGoalTypes');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'advisorId': advisorId,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map<String>((item) => item.toString()).toList();
      } else {
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
  Future<List<ProgressTracking>> getProgressDetailsByGoalType(int userId, int advisorId, String goalType) async {
    final url = Uri.parse('$baseUrl/getProgressDetailsByGoalType');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'advisorId': advisorId,
          'goalType': goalType,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<ProgressTracking> progressList = data.map((item) => ProgressTracking.fromJson(item)).toList();
        return progressList;
      } else {
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<void> updateProgressTracking(ProgressTracking progressTracking) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/progress-tracking/update'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'advisorName': progressTracking.advisorName,
          'userName': progressTracking.userName,
          'date': progressTracking.date.toIso8601String(),
          'goalType': progressTracking.goalType,
          'goal': progressTracking.goal,
          'actionSteps': progressTracking.actionSteps,
          'timeline': progressTracking.timeline,
          'progressDate': progressTracking.progressDate.toIso8601String(),
          'progressMade': progressTracking.progressMade,
          'effectivenessDate': progressTracking.effectivenessDate.toIso8601String(),
          'outcome': progressTracking.outcome,
          'nextSteps': progressTracking.nextSteps,
          'meetingDate': progressTracking.meetingDate.toIso8601String(),
          'agenda': progressTracking.agenda,
          'additionalNotes': progressTracking.additionalNotes,
          'progressStatus': progressTracking.progressStatus,
          'appointmentId': progressTracking.appointmentId,
        }),
      );

      if (response.statusCode == 200) {
        print('Progress tracking updated successfully');
      } else if (response.statusCode == 404) {
        print('Appointment ID not found');
      } else {
        throw Exception('Failed to update progress tracking');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<ProgramInitializer?> getProgramInitializerByID(int programId) async {
    final url = '$baseUrl/program-initializer/$programId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProgramInitializer(
          programId: data['programId'],
          programName: data['programName'],
          programDescription: data['programDescription'],
          organizationName: data['organizationName'],
          imageUrl: data['imageUrl'],
          coordinatorName: data['coordinatorName'],
          coordinatorEmail: data['coordinatorEmail'],
          coordinatorNumber: data['coordinatorNumber'],
        );
      } else {
        print('Program not found: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error retrieving program details: $e');
      return null;
    }
  }
  Future<List<String>> getProgramInitializerName() async {
    final url = '$baseUrl/program-initializer-names';
    List<String> programList = [];

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        programList = List<String>.from(jsonDecode(response.body));
      } else {
        print('Failed to retrieve program names: ${response.body}');
      }
    } catch (e) {
      print('Error retrieving program names: $e');
    }

    return programList;
  }

  Future<List<AppointmentsDetails>> getAppointmentsForMonth(int month, int year) async {
    final response = await http.get(Uri.parse('$baseUrl/getAppointmentsForMonth?month=$month&year=$year'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      return data.map((json) {
        return AppointmentsDetails(
          appointmentID: json['appointment_id'],
          date: DateTime.parse(json['date']),
          time: json['time'],
          advisorID: json['advisor_id'],
          mainService: json['main_service'],
          subService: json['sub_service'],
          userID: json['user_id'],
          // Parse any additional fields as needed
        );
      }).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }
  Future<Map<String, Map<int, int>>> getMentorMeetingCounts(int year) async {
    final response = await http.get(Uri.parse('$baseUrl/getMentorMeetingCounts/$year'));

    if (response.statusCode == 200) {
      try {
        // Decode the JSON data
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Parse the data into the expected format
        return data.map((key, value) {
          // Ensure that 'value' is a Map<String, dynamic> and cast it properly
          final monthCountMap = value as Map<String, dynamic>;

          return MapEntry(
            key,
            monthCountMap.map((month, count) {
              // Parse the month (key) to an integer and ensure count is an integer
              final parsedMonth = int.tryParse(month);
              final parsedCount = count as int?;

              if (parsedMonth == null || parsedCount == null) {
                throw Exception('Failed to parse month or count');
              }

              return MapEntry(parsedMonth, parsedCount);
            }),
          );
        });
      } catch (e) {
        throw Exception('Failed to parse JSON data: $e');
      }
    } else {
      // Handle the case where the response status is not 200
      throw Exception('Failed to load mentor meeting counts. Status code: ${response.statusCode}');
    }
  }

  Future<Map<String, Map<int, int>>> getMenteeMeetingCounts(int year) async {
    final response = await http.get(Uri.parse('$baseUrl/getMenteeMeetingCounts/$year'));

    if (response.statusCode == 200) {
      try {
        // Decode the JSON data
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Parse the data into the expected format
        return data.map((key, value) {
          // Ensure that 'value' is a Map<String, dynamic> and cast it properly
          final monthCountMap = value as Map<String, dynamic>;

          return MapEntry(
            key,
            monthCountMap.map((month, count) {
              // Parse the month (key) to an integer and ensure count is an integer
              final parsedMonth = int.tryParse(month);
              final parsedCount = count as int?;

              if (parsedMonth == null || parsedCount == null) {
                throw Exception('Failed to parse month or count');
              }
              return MapEntry(parsedMonth, parsedCount);
            }),
          );
        });
      } catch (e) {
        throw Exception('Failed to parse JSON data: $e');
      }
    } else {
      // Handle the case where the response status is not 200
      throw Exception('Failed to load mentee meeting counts');
    }
  }

  Future<List<AppointmentsDetails>> getUserAppointmentsAllDetails(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/appointments/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => AppointmentsDetails.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user appointments');
    }
  }

  Future<List<AppointmentsDetails>> getMentorAppointmentsAllDetails(int advisorId) async {
    final response = await http.get(Uri.parse('$baseUrl/mentor/appointments/$advisorId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => AppointmentsDetails.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load mentor appointments');
    }
  }

  Future<UserDetails?> getUserDetailsById(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
    if (response.statusCode == 200) {
      return UserDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user details');
    }
  }
}
