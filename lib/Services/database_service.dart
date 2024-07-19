import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:saloon/Models/appointments_details.dart';
import 'package:saloon/Models/edit_appointment_meeting.dart';
import 'package:saloon/Models/mentor_details.dart';
import 'package:saloon/Models/admin_service.dart';
import 'package:saloon/Models/mentor_service.dart';
import 'package:saloon/Models/progress_tracking.dart';
import 'package:saloon/Models/user_details.dart';

class DatabaseService {
  //Mentor All Details
  Future<List<MentorDetails>> getMentorDetails() async {
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
        'SELECT * FROM public.advisor_details',
      );

      await connection.close();

      List<MentorDetails> mentorDetailsList = [];

      for (var row in results) {
        mentorDetailsList.add(MentorDetails(
          name: row[0] as String,
          address: row[1] as String,
          mobile: row[2] as String,
          email: row[3] as String,
          pincode: row[4] as String,
          country: row[5] as String,
          state: row[6] as String,
          city: row[7] as String,
          area: row[8] as String,
          license: row[9] as String,
          workingDays: row[10] as String,
          timeSlots: row[11] as String,
          imageURL: row[12] as String,
          companyName: row[13] as String,
          designation: row[14] as String,
          gender: row[15] as String,
          dateOfBirth: row[16] as DateTime,
          advisorID: row[17] as int,
          password: row[18] as String,
        ));
      }

      return mentorDetailsList;
    } catch (e) {
      return [];
    }
  }
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

  //Mentor Services
  Future<List<MentorService>> getMentorServices() async {
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
        'SELECT * FROM public.advisor_service_details',
      );

      await connection.close();

      List<MentorService> mentorServiceList = [];

      for (var row in results) {
        mentorServiceList.add(MentorService(
          advisorID: row[0] as int,
          mainService: row[1] as String,
          subService: row[2] as String,
          rate: row[3] as int,
          quantity: row[4] as int,
          unitMeasurement: row[5] as String,
        ));
      }

      return mentorServiceList;
    } catch (e) {
      return [];
    }
  }

  //User Details
  Future<UserDetails?> getUserDetails(String email, String password) async {
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

      final results = await connection.execute(Sql.named('SELECT * FROM master_demo_user WHERE email = @email AND password = @password'),
        parameters: {
          'email': email,
          'password': password,
        },
      );

      await connection.close();

      if (results.isNotEmpty) {
        var row = results.first;
        return UserDetails(
          name: row[0] as String,
          password: row[1] as String,
          email: row[2] as String,
          number: row[3] as String,
          userID: row[4] as int,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  //Mentor Details Get By Email
  Future<MentorDetails?> getMentorByEmailDetails(String email, String password) async {
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

      final results = await connection.execute(Sql.named('SELECT * FROM advisor_details WHERE email = @email AND password = @password'),
        parameters: {
          'email': email,
          'password': password,
        },
      );

      await connection.close();

      if (results.isNotEmpty) {
        var row = results.first;
        return MentorDetails(
          name: row[0] as String,
          address: row[1] as String,
          mobile: row[2] as String,
          email: row[3] as String,
          pincode: row[4] as String,
          country: row[5] as String,
          state: row[6] as String,
          city: row[7] as String,
          area: row[8] as String,
          license: row[9] as String,
          workingDays: row[10] as String,
          timeSlots: row[11] as String,
          imageURL: row[12] as String,
          companyName: row[13] as String,
          designation: row[14] as String,
          gender: row[15] as String,
          dateOfBirth: row[16] as DateTime,
          advisorID: row[17] as int,
          password: row[18] as String,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  //User Appointment Find by User ID
  Future<List<AppointmentsDetails>> getUserAppointmentsAllDetails(int userID) async {
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

      final results = await connection.execute(Sql.named('SELECT * FROM appointments WHERE user_id = @userId'),
        parameters : {
        'userId': userID,
        },
      );

      await connection.close();

      List<AppointmentsDetails> appointmentsDetailsList = [];


      for (var row in results) {
        appointmentsDetailsList.add(AppointmentsDetails(
          appointmentID: row[0] as int,
          date: row[1] as DateTime,
          time: row[2] as String,
          advisorID: row[3] as int,
          mainService: row[4] as String,
          subService: row[5] as String,
          userID: row[6] as int,
        ));
      }

      return appointmentsDetailsList;
    } catch (e) {
      return [];
    }
  }

  //User Find by User ID
  Future<UserDetails?> getUserDetailsById(int userID) async {
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

      final results = await connection.execute(Sql.named('SELECT * FROM master_demo_user WHERE user_id = @userId'),
        parameters : {
          'userId': userID,
        },
      );

      await connection.close();

      if (results.isNotEmpty) {
        var row = results.first;
        return UserDetails(
          name: row[0] as String,
          password: row[1] as String,
          email: row[2] as String,
          number: row[3] as String,
          userID: row[4] as int,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  //Mentor Appointment Find by Mentor ID
  Future<List<AppointmentsDetails>> getMentorAppointmentsAllDetails(int advisorID) async {
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

      final results = await connection.execute(Sql.named('SELECT * FROM appointments WHERE advisor_id = @advisorID'),
        parameters : {
          'advisorID': advisorID,
        },
      );

      await connection.close();

      List<AppointmentsDetails> appointmentsDetailsList = [];


      for (var row in results) {
        appointmentsDetailsList.add(AppointmentsDetails(
          appointmentID: row[0] as int,
          date: row[1] as DateTime,
          time: row[2] as String,
          advisorID: row[3] as int,
          mainService: row[4] as String,
          subService: row[5] as String,
          userID: row[6] as int,
        ));
      }

      return appointmentsDetailsList;
    } catch (e) {
      return [];
    }
  }

  // Insert In the Mentor Meeting
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
     connection.execute(Sql.named('INSERT INTO mentor_meetings (user_id, advisor_id, title, meeting_date, start_time, end_time, location,  event_details, description, meeting_link, appointment_id) VALUES (@userId, @advisorId, @title, @meetingDate, @startTime, @endTime, @location, @eventDetails, @description, @meetingLink, @appointmentId)'),
        parameters: {
          'userId': userId,
          'advisorId': advisorId,
          'title': title,
          'meetingDate': meetingDate,
          'startTime': '${startTime.hour}:${startTime.minute}:00',
          'endTime': '${endTime.hour}:${endTime.minute}:00',
          'location': location,
          'eventDetails': eventDetails,
          'description': description,
          'meetingLink': meetingLink,
          'appointmentId':appointmentId,
        },
      );
    }

    //Get User meeting By date and time
  Future<EditAppointmentMeeting?> getUserMeetingDetails(DateTime date, TimeOfDay startTime) async {
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

        List<List<dynamic>> results = await connection.execute(Sql.named('SELECT * FROM mentor_meetings WHERE meetingDate = @meetingDate AND startTime = @startTime'),
          parameters: {
            'meetingDate': date.toIso8601String(),
            'startTime': startTime,
          },
        );

      await connection.close();

      if (results.isNotEmpty) {
        var row = results.first;
        return EditAppointmentMeeting(
          mentorID: row[0] as int,
          userID: row[1] as int,
          advisorID: row[2] as int,
          title: row[3] as String,
          meetDate: row[4] as DateTime,
          startTime: row[5] as TimeOfDay,
          endTime: row[6] as TimeOfDay,
          location:row[7] as String,
          eventDetails: [8] as String,
          description: [9] as String,
          meetLink: row[10] as String
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  //Get user User ID
  Future<String?> getUserName(int userId) async {
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
    final results = await connection.execute(Sql.named('SELECT name FROM master_demo_user WHERE user_id = @userId'),
      parameters: {'userId': userId},
    );
    await connection.close();
    return results.isNotEmpty ? results.first[0] as String : null;
  }

  //Get Advisor Name by Id
  Future<String?> getAdvisorName(int advisorId) async {
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
    final results = await connection.execute(Sql.named('SELECT name FROM advisor_details WHERE advisor_id = @advisorId'),
      parameters: {'advisorId': advisorId},
    );
    return results.isNotEmpty ? results.first[0] as String : 'Unknown Advisor';
  }

  //Insert in the Progress tracking
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
    required int appointmentId
  }) async {
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
    await connection.execute(Sql.named( '''
      INSERT INTO progress_tracking (
        advisor_id, advisor_name, user_id, user_name, date, goal_type, goal, 
        action_steps, timeline, progress_date, progress_made, 
        effectiveness_date, outcome, next_steps, meeting_date, agenda, additional_notes, appointment_id
      ) VALUES (
        @advisorId, @advisorName, @userId, @userName, @date, @goalType, @goal, 
        @actionSteps, @timeline, @progressDate, @progressMade, 
        @effectivenessDate, @outcome, @nextSteps, @meetingDate, @agenda, @additionalNotes, @appointmentId
      )
      '''),
      parameters: {
        'advisorId': advisorId,
        'advisorName': advisorName,
        'userId': userId,
        'userName': userName,
        'date': date,
        'goalType': goalType,
        'goal': goal,
        'actionSteps': actionSteps,
        'timeline': timeline,
        'progressDate': progressDate,
        'progressMade': progressMade,
        'effectivenessDate': effectivenessDate,
        'outcome': outcome,
        'nextSteps': nextSteps,
        'meetingDate': meetingDate,
        'agenda': agenda,
        'additionalNotes': additionalNotes,
        'appointmentId':appointmentId,
      },
    );
  }

  //Get Appointment by data,time,advisorID,main Service,Sub Service,UserID
  Future<int?> getAppointmentID(DateTime date,String time,int advisorID,String mainService,String subService,int userID) async {
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
    final results = await connection.execute(Sql.named('SELECT appointment_id FROM appointments WHERE user_id = @userId AND date = @date AND sub_service = @subService AND main_service = @mainService AND advisor_id = @advisorId AND time = @time'),
      parameters: {'date': date,'userId':userID,'subService':subService,'mainService':mainService,'advisorId':advisorID,'time':time},
    );
    await connection.close();
    return results.isNotEmpty ? results.first[0] as int : null;
  }
  Future<ProgressTracking?> getProgressTrackingByAppointmentId(int appointmentID) async {
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
        Sql.named('SELECT * FROM progress_tracking WHERE appointment_id = @appointmentID'),
        parameters: {
          'appointmentID': appointmentID,
        },
      );

      await connection.close();

      if (results.isNotEmpty) {
        var row = results.first;
        return ProgressTracking(
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
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
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
        Sql.named('SELECT DISTINCT goal_type FROM progress_tracking WHERE user_id = @userId AND advisor_id = @advisorId'),
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
  Future<List<ProgressTracking>> getProgressDetailsByGoalType(int userId, int advisorId, String goalType) async {
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
        Sql.named('SELECT * FROM progress_tracking WHERE user_id = @userId AND advisor_id = @advisorId AND goal_type = @goalType '),
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
      // Prepare the SQL statement
      await connection.execute(Sql.named('UPDATE progress_tracking SET advisor_name = @advisorName, '
          'user_name = @userName, date = @date, goal_type = @goalType, '
          'goal = @goal, action_steps = @actionSteps, timeline = @timeline, '
          'progress_date = @progressDate, progress_made = @progressMade, '
          'effectiveness_date = @effectivenessDate, outcome = @outcome, '
          'next_steps = @nextSteps, meeting_date = @meetingDate, '
          'agenda = @agenda, additional_notes = @additionalNotes, progress_status =@progressStatus '
          'WHERE appointment_id = @appointmentId'),
        parameters: {
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
          'progressStatus':progressTracking.progressStatus,
          'appointmentId': progressTracking.appointmentId,
        },
      );

      await connection.close();

      // Disconnect from the database
    } catch (e) {
      throw Exception('Failed to update progress tracking');
    }
  }
}

