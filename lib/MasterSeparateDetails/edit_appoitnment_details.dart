import 'package:flutter/material.dart';
import 'package:passionHub/Models/edit_appointment_meeting.dart';

class EditAppointmentPage extends StatelessWidget {
  final EditAppointmentMeeting appointmentDetails;

  const EditAppointmentPage({Key? key, required this.appointmentDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${appointmentDetails.meetDate.day}-${appointmentDetails.meetDate.month}-${appointmentDetails.meetDate.year}'),
            const SizedBox(height: 8.0),
            Text('Time: ${appointmentDetails.startTime.format(context)}'),
            const SizedBox(height: 8.0),
            Text('Main Service: ${appointmentDetails.eventDetails}'),
            const SizedBox(height: 8.0),
            Text('Sub Service: ${appointmentDetails.eventDetails}'),
            const SizedBox(height: 16.0),
            // Add more fields as needed and provide text fields for editing
            // For example:
            TextField(
              decoration: InputDecoration(
                labelText: 'Main Service',
                hintText: appointmentDetails.eventDetails,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Sub Service',
                hintText: appointmentDetails.eventDetails,
              ),
            ),
            // Add a save button
            ElevatedButton(
              onPressed: () {
                // Save the edited details
                // You can add the logic for saving here
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
