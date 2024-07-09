import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:saloon/Models/appointments_details.dart';
import 'package:saloon/Models/mentor_details.dart';
import 'package:saloon/Models/admin_service.dart';
import 'package:saloon/Models/mentor_service.dart';
import 'package:saloon/Models/user_details.dart';

class DatabaseService {
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
        ));
      }

      return mentorDetailsList;
    } catch (e) {
      return [];
    }
  }
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
  Future<List<AppointmentsDetails>> getUserAppointmentsDetails(int userID) async {
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

      List<AppointmentsDetails> AppointmentsDetailsList = [];


      for (var row in results) {
        AppointmentsDetailsList.add(AppointmentsDetails(
          appointmentID: row[0] as int,
          date: row[1] as DateTime,
          time: row[2] as String,
          advisorID: row[3] as int,
          mainService: row[4] as String,
          subService: row[5] as String,
          userID: row[6] as int,
        ));
      }

      return AppointmentsDetailsList;
    } catch (e) {
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
     connection.execute(Sql.named('INSERT INTO mentor_meetings (user_id, advisor_id, title, meeting_date, start_time, end_time, location,  event_details, description, meeting_link) VALUES (@userId, @advisorId, @title, @meetingDate, @startTime, @endTime, @location, @eventDetails, @description, @meetingLink)'),
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
        },
      );
    }
}
