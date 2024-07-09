import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:saloon/Services/database_service.dart';

class MentorMeetingPage extends StatefulWidget {
  final String title;
  final DateTime date;
  final String timeSlot;
  final String mainService;
  final String subService;
  final int userID;
  final int advisorID;

  const MentorMeetingPage({
    Key? key,
    required this.title,
    required this.date,
    required this.timeSlot,
    required this.mainService,
    required this.subService,
    required this.userID,
    required this.advisorID,
  }) : super(key: key);

  @override
  State<MentorMeetingPage> createState() => _MentorMeetingPageState();
}

class _MentorMeetingPageState extends State<MentorMeetingPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? timeZone = 'Time zone';
  bool doesNotRepeat = true;
  String notificationTime = '30 minutes';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notificationController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _meetingLinkController = TextEditingController();
  DatabaseService databaseService =DatabaseService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime ?? const TimeOfDay(hour: 9, minute: 0) : endTime ?? const TimeOfDay(hour: 11, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();  // 'jm' for AM/PM format
    return format.format(dt);
  }

  Future<void> _saveMeetingDetails() async {
    // Save meeting details to database
    await databaseService.insertMentorMeeting(
      userId: widget.userID,
      advisorId: widget.advisorID,
      title: _titleController.text,
      meetingDate: selectedDate,
      startTime: startTime!,
      endTime: endTime!,
      location: _locationController.text,
      eventDetails: '${widget.mainService} - ${widget.subService}',
      description: _descriptionController.text,
      meetingLink: _meetingLinkController.text,
    );

    // Send notifications to mentor and user
    await sendNotification('mentor@example.com', 'New Meeting Scheduled'); // Mentor's email
    await sendNotification('user@example.com', 'New Meeting Scheduled'); // User's email

  }

  Future<void> sendNotification(String recipientEmail, String subject) async {
    final Email email = Email(
      body: '''
    <h1>New Meeting Scheduled</h1>
    <p>Title: ${_titleController.text}</p>
    <p>Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}</p>
    <p>Time: ${formatTimeOfDay(startTime!)} - ${formatTimeOfDay(endTime!)}</p>
    <p>Location: ${_locationController.text}</p>
    <p>Notification Time: $notificationTime</p>
    <p>Details: ${widget.mainService} - ${widget.subService}</p>
    ''',
      subject: subject,
      recipients: [recipientEmail],
      isHTML: true,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      print('Failed to send email: $error');
    }
  }


  @override
  void initState() {
    super.initState();
    selectedDate = widget.date;
    final timeRange = widget.timeSlot.split(' - ');
    if (timeRange.length == 2) {
      final startParts = timeRange[0].split(':');
      final endParts = timeRange[1].split(':');
      startTime = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1].split(' ')[0]));
      endTime = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1].split(' ')[0]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Add title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${selectedDate.toLocal()}'.split(' ')[0],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          startTime != null ? formatTimeOfDay(startTime!) : 'Select Start Time',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          endTime != null ? formatTimeOfDay(endTime!) : 'Select End Time',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Text('Event Details',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
              Text('${widget.mainService} - ${widget.subService}',style: const TextStyle(fontSize: 21),),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: doesNotRepeat,
                    onChanged: (value) {
                      setState(() {
                        doesNotRepeat = value!;
                      });
                    },
                  ),
                  const Text('Does not repeat'),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Add location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('Notification'),
                  const SizedBox(width: 16.0),
                  DropdownButton<String>(
                    value: notificationTime,
                    items: <String>['10 minutes', '30 minutes', '1 hour']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        notificationTime = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _notificationController,
                decoration: const InputDecoration(
                  labelText: 'Add notification',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _guestsController,
                decoration: const InputDecoration(
                  labelText: 'Guests',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('Guest permissions'),
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                  ),
                  const Text('Modify event'),
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                  ),
                  const Text('Invite others'),
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                  ),
                  const Text('See guest list'),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Add description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _meetingLinkController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Meeting Link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _saveMeetingDetails,
                  child: const Text('Save Meeting'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
