import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:passionHub/MasterSeparateDetails/mentor_meeting_page.dart';
import 'package:passionHub/Models/mentor_details.dart';
import 'package:passionHub/Models/mentor_service.dart';
import 'package:passionHub/Models/user_details.dart';
import 'package:http/http.dart' as http;

class DetailPage extends StatefulWidget {
  final MentorDetails mentorDetails;
  final List<MentorService> masterServices;
  final UserDetails? userDetails;

  const DetailPage(
      {super.key,
      required this.mentorDetails,
      required this.masterServices,
      required this.userDetails});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  DateTime? selectedDate;
  String? selectedTimeSlot;
  Map<MentorService, bool> selectedServices = {};
  List<String> bookedTimeSlots = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize selected services map with false
    for (var service in widget.masterServices) {
      selectedServices[service] = false;
    }
    // Fetch existing appointments
    _fetchBookedTimeSlots();
  }
  Future<void> _fetchBookedTimeSlots() async {
    try {
      final response = await http.get(
        Uri.parse('https://mentor.passionit.com/mentor-api/booked-time-slots/${widget.mentorDetails.advisorID}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> slots = json.decode(response.body);

        setState(() {
          bookedTimeSlots = slots.map((slot) {
            return '${slot['date']} ${slot['time']}';
          }).toList();
        });
      } else {
        print('Failed to fetch booked time slots: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch booked time slots: $e');
    }
  }

  List<bool> parseWorkingDays(String workingDays) {
    List<dynamic> parsedList = jsonDecode(workingDays);
    return parsedList.map((e) => e as bool).toList();
  }

  List<String> parseTimeSlots(String timeSlots) {
    return timeSlots
        .substring(1, timeSlots.length - 1)
        .split(',')
        .map((s) => s.trim())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<bool> workingDaysList =
        parseWorkingDays(widget.mentorDetails.workingDays);
    List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    List<String> timeSlots = parseTimeSlots(widget.mentorDetails.timeSlots);

    // Filter MentorService data by advisorID
    List<MentorService> services = widget.masterServices
        .where((service) => service.advisorID == widget.mentorDetails.advisorID)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop Image
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: widget.mentorDetails.imageURL.isNotEmpty
                        ? Image.network(widget.mentorDetails.imageURL,
                            height: 200, width: 200, fit: BoxFit.cover)
                        : Container(
                            height: 200, width: 200, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Shop Basic Details in two columns
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildDetailItem(
                              Icons.person, 'Name', widget.mentorDetails.name),
                          _buildDetailItem(Icons.phone, 'Mobile',
                              widget.mentorDetails.mobile),
                          _buildDetailItem(Icons.pin_drop, 'Pincode',
                              widget.mentorDetails.pincode),
                          _buildDetailItem(Icons.location_city, 'City',
                              widget.mentorDetails.city),
                          _buildDetailItem(Icons.lock, 'License',
                              widget.mentorDetails.license),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _buildDetailItem(Icons.location_on, 'Address',
                              widget.mentorDetails.address),
                          _buildDetailItem(
                              Icons.email, 'Email', widget.mentorDetails.email),
                          _buildDetailItem(Icons.flag, 'Country',
                              widget.mentorDetails.country),
                          _buildDetailItem(
                              Icons.map, 'State', widget.mentorDetails.state),
                          _buildDetailItem(Icons.location_on, 'Area',
                              widget.mentorDetails.area),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // Working Days
                _buildWorkingDaysTable(workingDaysList, daysOfWeek),
                const SizedBox(height: 16.0),
                // Services
                _buildServicesTable(services),
                const SizedBox(height: 16.0),
                // Book Appointment Button
                Center(
                  child: ElevatedButton(
                    onPressed: () => _showDateTimePicker(
                        context, workingDaysList, timeSlots),
                    child: const Text('Book Appointment'),
                  ),
                ),
              ],
            ),
          ),
          // Circular Progress Indicator covering the entire screen
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.blue,),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30.0),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4.0),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingDaysTable(
      List<bool> workingDaysList, List<String> daysOfWeek) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Working Days:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Table(
          border: TableBorder.all(),
          children: daysOfWeek.map((day) {
            int index = daysOfWeek.indexOf(day);
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(day, style: const TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(workingDaysList[index] ? 'Open' : 'Closed',
                      style: const TextStyle(fontSize: 16)),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServicesTable(List<MentorService> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Services:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1),
          },
          children: [
            const TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Select',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Main Service',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Sub Service',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Quantity',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Rate',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Session',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...services.map((service) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Checkbox(
                      value: selectedServices[service],
                      onChanged: (bool? value) {
                        setState(() {
                          selectedServices[service] = value!;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(service.mainService,
                        style: const TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(service.subService,
                        style: const TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(service.quantity.toString(),
                        style: const TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(service.rate.toString(),
                        style: const TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(service.unitMeasurement,
                        style: const TextStyle(fontSize: 16)),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  void _showDateTimePicker(BuildContext context, List<bool> workingDaysList,
      List<String> timeSlots) async {
    DateTime now = DateTime.now();
    DateTime? initialDate = now.add(const Duration(days: 1)); // Start from tomorrow

    // Ensure the initialDate is a valid working day and not today
    while (initialDate != null && (!workingDaysList[initialDate.weekday - 1])) {
      initialDate = initialDate.add(const Duration(days: 1)); // Move to the next day
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      selectableDayPredicate: (DateTime date) {
        int dayIndex = date.weekday - 1; // Weekday starts from Monday as 1
        return date.isAfter(now) && workingDaysList[dayIndex]; // Disable today and non-working days
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });

      // Fetch booked time slots for the selected date
      List<String> bookedTimeSlotsForDate = bookedTimeSlots
          .where((slot) => slot
          .startsWith('${pickedDate.toLocal().toString().split(' ')[0]}'))
          .toList();

      // Check if all time slots are booked for the selected date
      bool allBookedForDate = bookedTimeSlotsForDate.length == timeSlots.length;

      if (allBookedForDate) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Date Unavailable'),
              content: const Text(
                  'All time slots for this date are booked. Please select another date.'),
              actions: [
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
      } else {
        // Enable picking a time slot
        String? pickedTimeSlot = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Select a Time Slot'),
              children: timeSlots.map((timeSlot) {
                String dateTimeString =
                    '${pickedDate.toLocal().toString().split(' ')[0]} $timeSlot';
                bool isBooked = bookedTimeSlots.contains(dateTimeString);

                return SimpleDialogOption(
                  onPressed: isBooked
                      ? null
                      : () {
                    Navigator.pop(context, timeSlot);
                  },
                  child: Text(
                    timeSlot,
                    style: TextStyle(
                      color: isBooked ? Colors.grey : Colors.black,
                      decoration: isBooked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );

        if (pickedTimeSlot != null) {
          setState(() {
            selectedTimeSlot = pickedTimeSlot;
          });

          _confirmAppointment(context);
        }
      }
    }
  }

  Future<void> _confirmAppointment(BuildContext context) async {
    setState(() {
      isLoading = true; // Start showing progress indicator
    });

    List<MentorService> selectedServicesList = selectedServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    final selectedMainServices = selectedServicesList.map((e) => e.mainService)
        .toList();
    final selectedSubServices = selectedServicesList.map((e) => e.subService)
        .toList();

    if (selectedDate != null &&
        selectedTimeSlot != null &&
        selectedServicesList.isNotEmpty) {
      try {
        // Prepare the data to be sent to the server
        final response = await http.post(
          Uri.parse('https://mentor.passionit.com/mentor-api/confirm-appointment'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'advisorId': widget.mentorDetails.advisorID,
            'userId': widget.userDetails!.userID,
            'date': selectedDate!.toIso8601String(),
            'timeSlot': selectedTimeSlot,
            'services': selectedServicesList.map((service) {
              return {
                'mainService': service.mainService,
                'subService': service.subService,
              };
            }).toList(),
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            isLoading = false; // Stop showing progress indicator
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MentorMeetingPage(
                    title: '',
                    date: selectedDate!,
                    timeSlot: selectedTimeSlot!,
                    mainService: selectedMainServices.join(', '),
                    subService: selectedSubServices.join(', '),
                    userID: widget.userDetails!.userID,
                    advisorID: widget.mentorDetails.advisorID,
                  ),
            ),
          );
        } else {
          throw Exception('Failed to confirm appointment');
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Failed to confirm appointment. Please try again.'),
              actions: [
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
        setState(() {
          isLoading = false; // Stop showing progress indicator on error
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Incomplete Selection'),
            content: const Text(
                'Please select a date, time slot, and at least one service.'),
            actions: [
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
      setState(() {
        isLoading =
        false; // Stop showing progress indicator on incomplete selection
      });
    }
  }
}
