class ProgressTracking {
  final int advisorId;
  final String advisorName;
  final int userId;
  final String userName;
  final DateTime date;
  final String goalType;
  final String goal;
  final String actionSteps;
  final String timeline;
  final DateTime progressDate;
  final String progressMade;
  final DateTime effectivenessDate;
  final String outcome;
  final String nextSteps;
  final DateTime meetingDate;
  final String agenda;
  final String additionalNotes;
  final int appointmentId;

  ProgressTracking({
    required this.advisorId,
    required this.advisorName,
    required this.userId,
    required this.userName,
    required this.date,
    required this.goalType,
    required this.goal,
    required this.actionSteps,
    required this.timeline,
    required this.progressDate,
    required this.progressMade,
    required this.effectivenessDate,
    required this.outcome,
    required this.nextSteps,
    required this.meetingDate,
    required this.agenda,
    required this.additionalNotes,
    required this.appointmentId,
  });
}
