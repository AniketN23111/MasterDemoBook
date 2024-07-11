import 'package:flutter/material.dart';

class EditAppointmentMeeting {
  final int mentorID;
  final int userID;
  final int advisorID;
  final String title;
  final DateTime meetDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;
  final String eventDetails;
  final String description;
  final String meetLink;

  EditAppointmentMeeting({
    required this.mentorID,
    required this.userID,
    required this.advisorID,
    required this.title,
    required this.meetDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.eventDetails,
    required this.description,
    required this.meetLink,
  });
}
