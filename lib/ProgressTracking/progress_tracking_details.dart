import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saloon/Models/progress_tracking.dart';
import 'package:saloon/Services/database_service.dart';

class ProgressTrackingDetailsPage extends StatefulWidget {
  final ProgressTracking progressTracking;
  final bool isMentor; // Add isMentor boolean flag

  const ProgressTrackingDetailsPage({
    super.key,
    required this.progressTracking,
    required this.isMentor, // Require the isMentor flag
  });

  @override
  State<ProgressTrackingDetailsPage> createState() =>
      _ProgressTrackingDetailsPageState();
}

class _ProgressTrackingDetailsPageState
    extends State<ProgressTrackingDetailsPage> {
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
  late String _progressStatus;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final List<String> _progressStatusOptions = [
    'Open',
    'Closed',
    'In Progress',
    'Hold'
  ];

  @override
  void initState() {
    super.initState();
    _advisorNameController =
        TextEditingController(text: widget.progressTracking.advisorName);
    _userNameController =
        TextEditingController(text: widget.progressTracking.userName);
    _dateController = TextEditingController(
        text: _dateFormat.format(widget.progressTracking.date));
    _goalTypeController =
        TextEditingController(text: widget.progressTracking.goalType);
    _goalController = TextEditingController(text: widget.progressTracking.goal);
    _actionStepsController =
        TextEditingController(text: widget.progressTracking.actionSteps);
    _timelineController =
        TextEditingController(text: widget.progressTracking.timeline);
    _progressDateController = TextEditingController(
        text: _dateFormat.format(widget.progressTracking.progressDate));
    _progressMadeController =
        TextEditingController(text: widget.progressTracking.progressMade);
    _effectivenessDateController = TextEditingController(
        text: _dateFormat.format(widget.progressTracking.effectivenessDate));
    _outcomeController =
        TextEditingController(text: widget.progressTracking.outcome);
    _nextStepsController =
        TextEditingController(text: widget.progressTracking.nextSteps);
    _meetingDateController = TextEditingController(
        text: _dateFormat.format(widget.progressTracking.meetingDate));
    _agendaController =
        TextEditingController(text: widget.progressTracking.agenda);
    _additionalNotesController =
        TextEditingController(text: widget.progressTracking.additionalNotes);
    _progressStatus = widget.progressTracking.progressStatus;
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
    // Show the circular progress indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        );
      },
    );

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
      progressStatus: _progressStatus,
    );

    await DatabaseService().updateProgressTracking(updatedProgressTracking);
    if (!mounted) return;
    Navigator.pop(context); // Close the progress dialog
    Navigator.pop(context); // Navigate back
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
                  _buildDataRowForDropdown(
                      'Progress Status', _progressStatusOptions, _progressStatus),
                  _buildDataRow('Effectiveness Date', _effectivenessDateController),
                  _buildDataRow('Outcome', _outcomeController),
                  _buildDataRow('Next Steps', _nextStepsController),
                  _buildDataRow('Meeting Date', _meetingDateController),
                  _buildDataRow('Agenda', _agendaController),
                  _buildDataRow('Additional Notes', _additionalNotesController),
                ],
              ),
              const SizedBox(height: 16.0),
              widget.isMentor
                  ? ElevatedButton(
                onPressed: _saveProgressTrackingDetails,
                child: const Text('Save'),
              )
                  : const SizedBox(), // Hide save button if not mentor
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
        Container(
          width: 200, // Set a fixed width for the text field
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: controller,
            maxLines: 1, // Allow single line input to avoid expanding the height
            enabled: widget.isMentor, // Enable editing only if isMentor is true
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFF0F0F0),
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.all(8.0),
            ),
            style: const TextStyle(
              overflow: TextOverflow.ellipsis, // Ellipsis for overflowed text
            ),
          ),
        ),
      ),
    ]);
  }

  DataRow _buildDataRowForDropdown(
      String label, List<String> options, String selectedValue) {
    return DataRow(cells: [
      DataCell(Text(label)),
      DataCell(
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: widget.isMentor
                ? (newValue) {
              setState(() {
                _progressStatus = newValue!;
              });
            }
                : null, // Disable dropdown if not mentor
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFF0F0F0),
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.all(8.0),
            ),
          ),
        ),
      ),
    ]);
  }
}
