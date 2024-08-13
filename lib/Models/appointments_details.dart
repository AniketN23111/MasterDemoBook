import 'package:intl/intl.dart';

class AppointmentsDetails {
  final int appointmentID;
  final DateTime date;
  final String time;
  final int advisorID;
  final String mainService;
  final String subService;
  final int userID;

  AppointmentsDetails({
    required this.appointmentID,
    required this.date,
    required this.time,
    required this.advisorID,
    required this.mainService,
    required this.subService,
    required this.userID,
  });

  factory AppointmentsDetails.fromJson(Map<String, dynamic> json) {
    final dateString = json['date'] as String;
    DateFormat dateFormat;

    // Determine the date format based on the string format
    if (dateString.contains('/')) {
      dateFormat = DateFormat('yyyy/MM/dd'); // Adjust this if the format is different
    } else {
      dateFormat = DateFormat('yyyy-MM-dd');
    }

    return AppointmentsDetails(
      appointmentID: int.tryParse(json['appointment_id']) ?? 0,
      date: dateFormat.parse(dateString),
      time: json['time'],
      advisorID: json['advisor_id'],
      mainService: json['main_service'],
      subService: json['sub_service'],
      userID: int.tryParse(json['user_id']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd'); // Adjust this format as needed

    return {
      'appointment_id': appointmentID,
      'date': dateFormat.format(date),
      'time': time,
      'advisor_id': advisorID,
      'main_service': mainService,
      'sub_service': subService,
      'user_id': userID,
    };
  }
}
