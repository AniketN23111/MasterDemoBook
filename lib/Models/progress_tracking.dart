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
  final String progressStatus;

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
    required this.progressStatus,
  });
  factory ProgressTracking.fromJson(Map<String, dynamic> json) {
    return ProgressTracking(
      advisorId:  json['advisor_id'],
      advisorName: json['advisor_name'],
      userId: json['user_id'],
      userName: json['user_name'],
      date: DateTime.parse(json['date']),
      goalType: json['goal_type'],
      goal: json['goal'],
      actionSteps: json['action_steps'],
      timeline: json['timeline'],
      progressDate: DateTime.parse(json['progress_date']),
      progressMade: json['progress_made'],
      effectivenessDate: DateTime.parse(json['effectiveness_date']),
      outcome: json['outcome'],
      nextSteps: json['next_steps'],
      meetingDate: DateTime.parse(json['meeting_date']),
      agenda: json['agenda'],
      additionalNotes: json['additional_notes'],
      appointmentId: int.tryParse(json['appointment_id']) ?? 0,
      progressStatus: json['progress_status'],
    );
  }
}
