import 'package:flutter/material.dart';
import 'package:saloon/Models/progress_tracking.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

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
    _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.progressTracking.date));
    _goalTypeController = TextEditingController(text: widget.progressTracking.goalType);
    _goalController = TextEditingController(text: widget.progressTracking.goal);
    _actionStepsController = TextEditingController(text: widget.progressTracking.actionSteps);
    _timelineController = TextEditingController(text: widget.progressTracking.timeline);
    _progressDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.progressTracking.progressDate));
    _progressMadeController = TextEditingController(text: widget.progressTracking.progressMade);
    _effectivenessDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.progressTracking.effectivenessDate));
    _outcomeController = TextEditingController(text: widget.progressTracking.outcome);
    _nextStepsController = TextEditingController(text: widget.progressTracking.nextSteps);
    _meetingDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.progressTracking.meetingDate));
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

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.parse(controller.text);
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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

   // await DatabaseService().updateProgressTracking(updatedProgressTracking);

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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Advisor Name')),
                    DataColumn(label: Text('User Name')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Goal Type')),
                    DataColumn(label: Text('Goal')),
                    DataColumn(label: Text('Action Steps')),
                    DataColumn(label: Text('Timeline')),
                    DataColumn(label: Text('Progress Date')),
                    DataColumn(label: Text('Progress Made')),
                    DataColumn(label: Text('Effectiveness Date')),
                    DataColumn(label: Text('Outcome')),
                    DataColumn(label: Text('Next Steps')),
                    DataColumn(label: Text('Meeting Date')),
                    DataColumn(label: Text('Agenda')),
                    DataColumn(label: Text('Additional Notes')),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(TextField(controller: _advisorNameController)),
                        DataCell(TextField(controller: _userNameController)),
                        DataCell(
                          GestureDetector(
                            onTap: () => _selectDate(context, _dateController),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _dateController,
                                decoration: const InputDecoration(
                                  hintText: 'Select Date',
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(TextField(controller: _goalTypeController)),
                        DataCell(TextField(controller: _goalController)),
                        DataCell(TextField(controller: _actionStepsController)),
                        DataCell(TextField(controller: _timelineController)),
                        DataCell(
                          GestureDetector(
                            onTap: () => _selectDate(context, _progressDateController),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _progressDateController,
                                decoration: const InputDecoration(
                                  hintText: 'Select Date',
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(TextField(controller: _progressMadeController)),
                        DataCell(
                          GestureDetector(
                            onTap: () => _selectDate(context, _effectivenessDateController),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _effectivenessDateController,
                                decoration: const InputDecoration(
                                  hintText: 'Select Date',
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(TextField(controller: _outcomeController)),
                        DataCell(TextField(controller: _nextStepsController)),
                        DataCell(
                          GestureDetector(
                            onTap: () => _selectDate(context, _meetingDateController),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _meetingDateController,
                                decoration: const InputDecoration(
                                  hintText: 'Select Date',
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(TextField(controller: _agendaController)),
                        DataCell(TextField(controller: _additionalNotesController)),
                      ],
                    ),
                  ],
                ),
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
}
