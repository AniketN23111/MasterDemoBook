import 'package:postgres/postgres.dart';
import 'package:saloon/Models/mentor_details.dart';
import 'package:saloon/Models/mentor_service.dart';

class DatabaseService {
  final connection = Connection.open(
    Endpoint(
      host: '34.71.87.187',
      port: 5432,
      database: 'airegulation_dev',
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
          database: 'airegulation_dev',
          username: 'postgres',
          password: 'India@5555',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      final results = await connection.execute(
        'SELECT * FROM ai.master_details',
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
          services: row[12] as String,
          rate: row[13] as int,
          quantity: row[14] as int,
          unitMeasurement: row[15] as String,
          imageURl: row[16] as String,
        ));
      }

      return MentorDetailsList;
    } catch (e) {
      return [];
    }
  }
  Future<List<MentorService>> getMentorService() async {
    try {
      final connection = await Connection.open(
        Endpoint(
          host: '34.71.87.187',
          port: 5432,
          database: 'airegulation_dev',
          username: 'postgres',
          password: 'India@5555',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      final results = await connection.execute(
        'SELECT * FROM ai.service_master',
      );

      await connection.close();

      List<MentorService> MentorServiceList = [];

      for (var row in results) {
        MentorServiceList.add(MentorService(
          service: row[0] as String,
          subService: row[1] as String,
          imageIcon: row[2] as String,
        ));
      }

      return MentorServiceList;
    } catch (e) {
      return [];
    }
  }
}
