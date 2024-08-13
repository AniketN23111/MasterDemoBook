import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:saloon/Models/appointments_details.dart';
import 'package:saloon/Models/admin_service.dart';
import 'package:saloon/Models/mentor_service.dart';
import 'package:saloon/Models/program_initializer.dart';
import 'package:saloon/Models/progress_tracking.dart';
import 'package:saloon/Models/user_details.dart';
import 'package:http/http.dart' as http;

class DatabaseService {
  final String baseUrl = 'http://localhost:3000';

  //Admin Stored Services Get
  Future<List<AdminService>> getAdminService() async {
    try {
      final connection = await Connection.open(
        Endpoint(
          host: '34.71.87.187',
          port: 5432,
          database: 'datagovernance',
          username: 'postgres',
          password: 'India@5555',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      final results = await connection.execute(
        'SELECT * FROM public.service_master',
      );

      await connection.close();

      List<AdminService> adminServiceList = [];

      for (var row in results) {
        adminServiceList.add(AdminService(
          service: row[0] as String,
          subService: row[1] as String,
          imageIcon: row[2] as String,
        ));
      }

      return adminServiceList;
    } catch (e) {
      return [];
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
    try {
      final connection = await Connection.open(
        Endpoint(
          host: '34.71.87.187',
          port: 5432,
          database: 'datagovernance',
          username: 'postgres',
          password: 'India@5555',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      final results = await connection.execute(
        Sql.named(
            'SELECT DISTINCT goal_type FROM progress_tracking WHERE user_id = @userId AND advisor_id = @advisorId'),
        parameters: {
          'userId': userId,
          'advisorId': advisorId,
        },
      );

      await connection.close();

      List<String> goalTypes = results.map((row) => row[0] as String).toList();

      return goalTypes;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return [];
    }
  }

  Future<List<ProgressTracking>> getProgressDetailsByGoalType(
      int userId, int advisorId, String goalType) async {
    try {
      final connection = await Connection.open(
        Endpoint(
          host: '34.71.87.187',
          port: 5432,
          database: 'datagovernance',
          username: 'postgres',
          password: 'India@5555',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      final results = await connection.execute(
        Sql.named(
            'SELECT * FROM progress_tracking WHERE user_id = @userId AND advisor_id = @advisorId AND goal_type = @goalType '),
        parameters: {
          'userId': userId,
          'advisorId': advisorId,
          'goalType': goalType,
        },
      );

      await connection.close();

      List<ProgressTracking> progressList = [];

      for (var row in results) {
        progressList.add(ProgressTracking(
          advisorId: row[1] as int,
          advisorName: row[2] as String,
          userId: row[3] as int,
          userName: row[4] as String,
          date: row[5] as DateTime,
          goalType: row[6] as String,
          goal: row[7] as String,
          actionSteps: row[8] as String,
          timeline: row[9] as String,
          progressDate: row[10] as DateTime,
          progressMade: row[11] as String,
          effectivenessDate: row[12] as DateTime,
          outcome: row[13] as String,
          nextSteps: row[14] as String,
          meetingDate: row[15] as DateTime,
          agenda: row[16] as String,
          additionalNotes: row[17] as String,
          appointmentId: row[18] as int,
          progressStatus: row[19] as String,
        ));
      }

      return progressList;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
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


  Future<String> _getMentorName(int advisorId) async {
    final connection = await Connection.open(
      Endpoint(
        host: '34.71.87.187',
        port: 5432,
        database: 'datagovernance',
        username: 'postgres',
        password: 'India@5555',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    // Replace with your actual query to fetch mentor name
    const query =
        'SELECT name FROM advisor_details WHERE advisor_id = @advisorId';
    final result = await connection
        .execute(Sql.named(query), parameters: {'advisorId': advisorId});

    if (result.isNotEmpty) {
      return result.first.toColumnMap()['name'] as String;
    } else {
      return 'Unknown'; // Default value if mentor name is not found
    }
  }

  Future<Map<String, Map<int, int>>> getMentorMeetingCounts(int year) async {
    final connection = await Connection.open(
      Endpoint(
        host: '34.71.87.187',
        port: 5432,
        database: 'datagovernance',
        username: 'postgres',
        password: 'India@5555',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
    // Replace with your actual query to fetch data
    final query = '''
      SELECT advisor_id, EXTRACT(MONTH FROM date) as Month, COUNT(*) AS meeting_count
      FROM appointments
      WHERE EXTRACT(YEAR FROM date) = $year
      GROUP BY advisor_id, EXTRACT(MONTH FROM date)
    ''';

    final result = await connection.execute(Sql.named(query));

    final data = <String, Map<int, int>>{};

    for (var row in result) {
      final advisorId = row[0] as int;
      final monthString = row[1] as String;
      final meetingCount = row[2] as int;
      final month = int.tryParse(monthString) ?? 0;
      final mentorName = await _getMentorName(
          advisorId); // Method to fetch mentor name from ID

      // Create a unique key combining advisor_id and name
      final uniqueKey = '$mentorName (ID: $advisorId)';

      if (!data.containsKey(uniqueKey)) {
        data[uniqueKey] = {};
      }

      data[uniqueKey]![month] = meetingCount;
    }

    return data.map((uniqueKey, meetingCounts) {
      return MapEntry(uniqueKey, meetingCounts);
    });
  }

  Future<String> _getMenteeName(int userID) async {
    final connection = await Connection.open(
      Endpoint(
        host: '34.71.87.187',
        port: 5432,
        database: 'datagovernance',
        username: 'postgres',
        password: 'India@5555',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    // Replace with your actual query to fetch mentor name
    const query = 'SELECT name FROM master_demo_user WHERE user_id = @userId';
    final result = await connection
        .execute(Sql.named(query), parameters: {'userId': userID});

    if (result.isNotEmpty) {
      return result.first.toColumnMap()['name'] as String;
    } else {
      return 'Unknown'; // Default value if mentor name is not found
    }
  }

  Future<Map<String, Map<int, int>>> getMenteeMeetingCounts(int year) async {
    final connection = await Connection.open(
      Endpoint(
        host: '34.71.87.187',
        port: 5432,
        database: 'datagovernance',
        username: 'postgres',
        password: 'India@5555',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    final results = await connection.execute(
      Sql.named('''
        SELECT user_id,EXTRACT(MONTH FROM date) AS month, COUNT(*) AS count
        FROM appointments
        WHERE EXTRACT(YEAR FROM date) = @year
        GROUP BY user_id,EXTRACT(MONTH FROM date)
        '''),
      parameters: {'year': year},
    );

    await connection.close();

    final data = <String, Map<int, int>>{};

    for (var row in results) {
      final userID = row[0] as int;
      final monthString = row[1] as String;
      int count = row[2] as int;
      final month = int.tryParse(monthString) ?? 0;
      final menteeName = await _getMenteeName(userID);

      // Create a unique key combining advisor_id and name
      final uniqueKey = '$menteeName (ID: $userID)';

      if (!data.containsKey(uniqueKey)) {
        data[uniqueKey] = {};
      }

      data[uniqueKey]![month] = count;
    }

    return data.map((uniqueKey, meetingCounts) {
      return MapEntry(uniqueKey, meetingCounts);
    });
  }
  Future<List<AppointmentsDetails>> getAppointmentsForMonth(int month, int year) async {
    final connection = await Connection.open(
      Endpoint(
        host: '34.71.87.187',
        port: 5432,
        database: 'datagovernance',
        username: 'postgres',
        password: 'India@5555',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    const query = '''
    SELECT * FROM appointments
    WHERE EXTRACT(MONTH FROM date) = @month
    AND EXTRACT(YEAR FROM date) = @year
  ''';

    final result = await connection.execute(Sql.named(query), parameters: {'month': month, 'year': year});

    // Parse the result into a list of Appointment objects
    final appointments = result.map((row) {
      return AppointmentsDetails(
          appointmentID: row[0] as int,
        date: row[1] as DateTime,
        time: row[2] as String,
        advisorID:  row[3] as int,
        mainService: row[4] as String,
          subService: row[5] as String,
          userID: row[6] as int,
        // Add more fields as needed
      );
    }).toList();

    return appointments;
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
