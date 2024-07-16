import 'package:flutter/material.dart';
import 'package:saloon/Models/progress_tracking.dart';
import 'package:saloon/Services/database_service.dart';

class ProgressTrackingDetailsPage extends StatefulWidget {
  final ProgressTracking progressTracking;

  const ProgressTrackingDetailsPage({Key? key, required this.progressTracking}) : super(key: key);

  @override
  _ProgressTrackingDetailsPageState createState() => _ProgressTrackingDetailsPageState();
}

class _ProgressTrackingDetailsPageState extends State<ProgressTrackingDetailsPage> {
  late TextEditingController _advisorNameController;
  late TextEditingController _userNameController;
  late TextEditingController _dateController;
  late TextEditingController _goalTypeController;
  late TextEditingController _goalController;
  late TextEditingController _actionStepsController;
  late TextEditingController _timelineController;
  late TextEditingController _progressDateController;
  late TextEditingController _progressMadeController;
  late TextEditingController _effectivenessDateController;
  late TextEditingController _outcomeController;
  late TextEditingController _nextStepsController;
  late TextEditingController _meetingDateController;
  late TextEditingController _agendaController;
  late TextEditingController _additionalNotesController;

  @override
  void initState() {
    super.initState();
    _advisorNameController = TextEditingController(text: widget.progressTracking.advisorName);
    _userNameController = TextEditingController(text: widget.progressTracking.userName);
    _dateController = TextEditingController(text: widget.progressTracking.date.toIso8601String());
    _goalTypeController = TextEditingController(text: widget.progressTracking.goalType);
    _goalController = TextEditingController(text: widget.progressTracking.goal);
    _actionStepsController = TextEditingController(text: widget.progressTracking.actionSteps);
    _timelineController = TextEditingController(text: widget.progressTracking.timeline);
    _progressDateController = TextEditingController(text: widget.progressTracking.progressDate.toIso8601String());
    _progressMadeController = TextEditingController(text: widget.progressTracking.progressMade);
    _effectivenessDateController = TextEditingController(text: widget.progressTracking.effectivenessDate.toIso8601String());
    _outcomeController = TextEditingController(text: widget.progressTracking.outcome);
    _nextStepsController = TextEditingController(text: widget.progressTracking.nextSteps);
    _meetingDateController = TextEditingController(text: widget.progressTracking.meetingDate.toIso8601String());
    _agendaController = TextEditingController(text: widget.progressTracking.agenda);
    _additionalNotesController = TextEditingController(text: widget.progressTracking.additionalNotes);
  }

  @override
  void dispose() {
    _advisorNameController.dispose();
    _userNameController.dispose();
    _dateController.dispose();
    _goalTypeController.dispose();
    _goalController.dispose();
    _actionStepsController.dispose();
    _timelineController.dispose();
    _progressDateController.dispose();
    _progressMadeController.dispose();
    _effectivenessDateController.dispose();
    _outcomeController.dispose();
    _nextStepsController.dispose();
    _meetingDateController.dispose();
    _agendaController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  void _saveProgressTrackingDetails() async {
    ProgressTracking updatedProgressTracking = ProgressTracking(
      advisorId: widget.progressTracking.advisorId,
      advisorName: _advisorNameController.text,
      userId: widget.progressTracking.userId,
      userName: _userNameController.text,
      date: DateTime.parse(_dateController.text),
      goalType: _goalTypeController.text,
      goal: _goalController.text,
      actionSteps: _actionStepsController.text,
      timeline: _timelineController.text,
      progressDate: DateTime.parse(_progressDateController.text),
      progressMade: _progressMadeController.text,
      effectivenessDate: DateTime.parse(_effectivenessDateController.text),
      outcome: _outcomeController.text,
      nextSteps: _nextStepsController.text,
      meetingDate: DateTime.parse(_meetingDateController.text),
      agenda: _agendaController.text,
      additionalNotes: _additionalNotesController.text,
      appointmentId: widget.progressTracking.appointmentId,
    );

    await DatabaseService().updateProgressTracking(updatedProgressTracking);

    // Optionally, show a confirmation message or navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DataTable(
                columns: const [
                  DataColumn(label: Text('Field')),
                  DataColumn(label: Text('Value')),
                ],
                rows: [
                  _buildDataRow('Mentor Name', _advisorNameController),
                  _buildDataRow('Mentee Name', _userNameController),
                  _buildDataRow('Date', _dateController),
                  _buildDataRow('Goal Type', _goalTypeController),
                  _buildDataRow('Goal', _goalController),
                  _buildDataRow('Action Steps', _actionStepsController),
                  _buildDataRow('Timeline', _timelineController),
                  _buildDataRow('Progress Date', _progressDateController),
                  _buildDataRow('Progress Made', _progressMadeController),
                  _buildDataRow('Effectiveness Date', _effectivenessDateController),
                  _buildDataRow('Outcome', _outcomeController),
                  _buildDataRow('Next Steps', _nextStepsController),
                  _buildDataRow('Meeting Date', _meetingDateController),
                  _buildDataRow('Agenda', _agendaController),
                  _buildDataRow('Additional Notes', _additionalNotesController),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveProgressTrackingDetails,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(String label, TextEditingController controller) {
    return DataRow(cells: [
      DataCell(Text(label)),
      DataCell(
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            isDense: true,
          ),
        ),
      ),
    ]);
  }
}
