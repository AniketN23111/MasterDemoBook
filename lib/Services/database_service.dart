import 'package:postgres/postgres.dart';
import 'package:saloon/Models/master_details.dart';
import 'package:saloon/Models/master_service.dart';

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

  Future<List<MasterDetails>> getMasterDetails() async {
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

      List<MasterDetails> MasterDetailsList = [];

      for (var row in results) {
        MasterDetailsList.add(MasterDetails(
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
        ));
      }

      return MasterDetailsList;
    } catch (e) {
      return [];
    }
  }
  Future<List<MasterService>> getMasterService() async {
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

      List<MasterService> MasterServiceList = [];

      for (var row in results) {
        MasterServiceList.add(MasterService(
          service: row[0] as String,
          subService: row[1] as String,
          imageIcon: row[2] as String,
          rate: row[3] as int,
          quantity: row[4] as String,
        ));
      }

      return MasterServiceList;
    } catch (e) {
      return [];
    }
  }
}
