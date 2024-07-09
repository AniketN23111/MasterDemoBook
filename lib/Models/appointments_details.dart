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
}
