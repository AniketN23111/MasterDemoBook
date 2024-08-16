import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:passionHub/HomeScreen/my_home_page.dart';
import 'package:passionHub/Services/database_service.dart';

class MentorMeetingPage extends StatefulWidget {
  final String title;
  final DateTime date;
  final String timeSlot;
  final String mainService;
  final String subService;
  final int userID;
  final int advisorID;

  const MentorMeetingPage({
    super.key,
    required this.title,
    required this.date,
    required this.timeSlot,
    required this.mainService,
    required this.subService,
    required this.userID,
    required this.advisorID,
  });

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
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _meetingLinkController = TextEditingController();
  final TextEditingController _guestEmailController = TextEditingController();
  List<String> guests = [];
  DatabaseService databaseService = DatabaseService();

  List<String> programDetails = [];
  String? selectedProgram;

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      List<String> mainServices = widget.mainService.split(', ');
      List<String> subServices = widget.subService.split(', ');

      String? userName = await databaseService.getUserName(widget.userID);
      String? advisorName = await databaseService.getAdvisorName(widget.advisorID);
      int? appointmentID = await databaseService.getAppointmentID(widget.date, widget.timeSlot, widget.advisorID, widget.mainService, widget.subService, widget.userID);

      // Save meeting details to database
      for (int i = 0; i < mainServices.length; i++) {
        await databaseService.insertProgressTracking(
          advisorId: widget.advisorID,
          advisorName: advisorName!,
          userId: widget.userID,
          userName: userName!,
          date: selectedDate,
          goalType: 'Meeting',
          goal: _titleController.text,
          actionSteps: '${mainServices[i]} - ${subServices[i]}',
          timeline: '${formatTimeOfDay(startTime!)} - ${formatTimeOfDay(endTime!)}',
          progressDate: selectedDate,
          progressMade: '',
          effectivenessDate: selectedDate,
          outcome: '',
          nextSteps: '',
          meetingDate: selectedDate,
          agenda: _descriptionController.text,
          additionalNotes: _meetingLinkController.text,
          appointmentId: appointmentID!,
        );
      }

      for (int i = 0; i < mainServices.length; i++) {
        await databaseService.insertMentorMeeting(
          userId: widget.userID,
          advisorId: widget.advisorID,
          title: _titleController.text,
          meetingDate: selectedDate,
          startTime: startTime!,
          endTime: endTime!,
          location: _locationController.text,
          eventDetails: '${mainServices[i]} - ${subServices[i]}',
          description: _descriptionController.text,
          meetingLink: _meetingLinkController.text,
          appointmentId: appointmentID!,
        );
      }

      if (!mounted) return;

      // Send notifications to mentor and user
      //await sendNotification('aniketnarayankar3@gmail.com', 'New Meeting Scheduled');
      //await sendNotification('primesolus2311@gmail.com', 'New Meeting Scheduled'); // User's email

      Navigator.pop(context); // Dismiss the loading dialog
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage()));
    } catch (e) {
      Navigator.pop(context); // Dismiss the loading dialog in case of an error
      // Handle the error (e.g., show a Snackbar or a dialog with an error message)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to save meeting details: $e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

 /* Future<void> sendNotification(String recipientEmail, String subject) async {
    String username = 'sakshikadam1892001@gmail.com';
    String password = 'hjfg apya uqde svpk';
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = '''
      A new meeting has been scheduled.
      
      Title: ${_titleController.text}
      Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}
      Time: ${formatTimeOfDay(startTime!)} - ${formatTimeOfDay(endTime!)}
      Location: ${_locationController.text}
      Notification Time: $notificationTime
      Details: ${widget.mainService} - ${widget.subService}
      Description: ${_descriptionController.text}
      Meeting Link: ${_meetingLinkController.text}
      ''';

    try {
      await send(message, smtpServer);
      print('Email sent successfully');
    } catch (error) {
      print('Failed to send email: $error');
    }
  }*/

  void _addGuestEmail() {
    if (_guestEmailController.text.isNotEmpty) {
      setState(() {
        guests.add(_guestEmailController.text);
        _guestEmailController.clear();
      });
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
    _fetchProgramDetails();
  }

  Future<void> _fetchProgramDetails() async {
    List<String> programs = await databaseService.getProgramInitializerName();
    setState(() {
      programDetails = programs;
    });
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
              ListTile(
                title: const Text('Select date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ListTile(
                      title: const Text('Start time'),
                      subtitle: Text(startTime != null ? formatTimeOfDay(startTime!) : 'Select start time'),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () => _selectTime(context, true),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ListTile(
                      title: const Text('End time'),
                      subtitle: Text(endTime != null ? formatTimeOfDay(endTime!) : 'Select end time'),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: selectedProgram,
                items: programDetails.map((program) {
                  return DropdownMenuItem(
                    value: program,
                    child: Text(program),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProgram = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Program',
                  border: OutlineInputBorder(),
                ),
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
              TextField(
                controller: _notificationController,
                decoration: const InputDecoration(
                  labelText: 'Notification time before',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Add description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _meetingLinkController,
                decoration: const InputDecoration(
                  labelText: 'Add meeting link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _guestEmailController,
                decoration: InputDecoration(
                  labelText: 'Add guest email',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addGuestEmail,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Wrap(
                spacing: 8.0,
                children: guests.map((guest) {
                  return Chip(
                    label: Text(guest),
                    onDeleted: () {
                      setState(() {
                        guests.remove(guest);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveMeetingDetails,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
