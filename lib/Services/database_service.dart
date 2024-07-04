import 'package:postgres/postgres.dart';
import 'package:saloon/Models/mentor_details.dart';
import 'package:saloon/Models/admin_service.dart';
import 'package:saloon/Models/mentor_service.dart';

class DatabaseService {
  final connection = Connection.open(
    Endpoint(
      host: '34.71.87.187',
      port: 5432,
      database: 'datagovernance',
      username: 'postgres',
      password: 'India@5555',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );

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
        'SELECT * FROM public.master_details',
      );

      await connection.close();

      List<MentorDetails> MentorDetailsList = [];

      for (var row in results) {
        MentorDetailsList.add(MentorDetails(
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
          shopID: row[17] as int,
        ));
      }

      return MentorDetailsList;
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

      List<AdminService> AdminServiceList = [];

      for (var row in results) {
        AdminServiceList.add(AdminService(
          service: row[0] as String,
          subService: row[1] as String,
          imageIcon: row[2] as String,
        ));
      }

      return AdminServiceList;
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
        'SELECT * FROM public.service_details',
      );

      await connection.close();

      List<MentorService> mentorServiceList = [];

      for (var row in results) {
        mentorServiceList.add(MentorService(
          shopId: row[0] as int,
          mainService: row[1] as String,
          subService: row[2] as String,
          rate: row[3] as int,
          quantity: row[4] as int,
          unitMeasurement: row[5] as String,
        ));
      }

      return mentorServiceList;
    } catch (e) {
      print('Error fetching Mentor Services: $e');
      return [];
    }
  }
}
