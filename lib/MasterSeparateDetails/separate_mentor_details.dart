import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:saloon/MasterSeparateDetails/mentor_meeting_page.dart';
import 'package:saloon/Models/mentor_details.dart';
import 'package:saloon/Models/mentor_service.dart';

class DetailPage extends StatefulWidget {
  final MentorDetails masterDetails;
  final List<MentorService> masterServices;

  const DetailPage({Key? key, required this.masterDetails, required this.masterServices}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  DateTime? selectedDate;
  String? selectedTimeSlot;
  Map<MentorService, bool> selectedServices = {};
  List<String> bookedTimeSlots = [];

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
     Connection connection = await Connection.open(
        Endpoint(
          host: '34.71.87.187',
          port: 5432,
          database: 'datagovernance',
          username: 'postgres',
          password: 'India@5555',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      final results = await connection.execute(Sql.named('SELECT date, time FROM appointments WHERE advisor_id = @advisorId'),
        parameters: {
          'advisorId': widget.masterDetails.shopID,
        },
      );

      await connection.close();

      setState(() {
        bookedTimeSlots = results.map((row) {
          final date = row[0] as DateTime;
          final time = row[1] as String;
          return '${date.toLocal().toString().split(' ')[0]} $time';
        }).toList();
      });
    } catch (e) {
      print('Failed to fetch booked time slots: $e');
    }
  }

  List<bool> parseWorkingDays(String workingDays) {
    List<dynamic> parsedList = jsonDecode(workingDays);
    return parsedList.map((e) => e as bool).toList();
  }

  List<String> parseTimeSlots(String timeSlots) {
    return timeSlots.substring(1, timeSlots.length - 1).split(',').map((s) => s.trim()).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<bool> workingDaysList = parseWorkingDays(widget.masterDetails.workingDays);
    List<String> daysOfWeek = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    List<String> timeSlots = parseTimeSlots(widget.masterDetails.timeSlots);

    // Filter MentorService data by shopId
    List<MentorService> services = widget.masterServices.where((service) => service.shopId == widget.masterDetails.shopID).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: widget.masterDetails.imageURL.isNotEmpty
                    ? Image.network(widget.masterDetails.imageURL, height: 200, width: 200, fit: BoxFit.cover)
                    : Container(height: 200, width: 200, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16.0),
            // Shop Basic Details in two columns
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildDetailItem(Icons.person, 'Name', widget.masterDetails.name),
                      _buildDetailItem(Icons.phone, 'Mobile', widget.masterDetails.mobile),
                      _buildDetailItem(Icons.pin_drop, 'Pincode', widget.masterDetails.pincode),
                      _buildDetailItem(Icons.location_city, 'City', widget.masterDetails.city),
                      _buildDetailItem(Icons.lock, 'License', widget.masterDetails.license),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildDetailItem(Icons.location_on, 'Address', widget.masterDetails.address),
                      _buildDetailItem(Icons.email, 'Email', widget.masterDetails.email),
                      _buildDetailItem(Icons.flag, 'Country', widget.masterDetails.country),
                      _buildDetailItem(Icons.map, 'State', widget.masterDetails.state),
                      _buildDetailItem(Icons.location_on, 'Area', widget.masterDetails.area),
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
                onPressed: () => _showDateTimePicker(context, workingDaysList, timeSlots),
                child: const Text('Book Appointment'),
              ),
            ),
            const SizedBox(height: 16.0),

          ],
        ),
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
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4.0),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingDaysTable(List<bool> workingDaysList, List<String> daysOfWeek) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Working Days:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  child: Text(workingDaysList[index] ? 'Open' : 'Closed', style: const TextStyle(fontSize: 16)),
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
        const Text('Services:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  child: Text('Select', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Main Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Sub Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Rate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    child: Text(service.mainService, style: const TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(service.subService, style: const TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(service.quantity.toString(), style: const TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(service.rate.toString(), style: const TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(service.unitMeasurement, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  void _showDateTimePicker(BuildContext context, List<bool> workingDaysList, List<String> timeSlots) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      selectableDayPredicate: (DateTime date) {
        int dayIndex = date.weekday - 1; // Weekday starts from Monday as 1
        return workingDaysList[dayIndex];
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });

      // Fetch booked time slots for the selected date
      List<String> bookedTimeSlotsForDate = bookedTimeSlots
          .where((slot) => slot.startsWith('${pickedDate.toLocal().toString().split(' ')[0]}'))
          .toList();

      // Check if all time slots are booked for the selected date
      bool allBookedForDate = bookedTimeSlotsForDate.length == timeSlots.length;

      if (allBookedForDate) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Date Unavailable'),
              content: const Text('All time slots for this date are booked. Please select another date.'),
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
                String dateTimeString = '${pickedDate.toLocal().toString().split(' ')[0]} $timeSlot';
                bool isBooked = bookedTimeSlots.contains(dateTimeString);

                return SimpleDialogOption(
                  onPressed: isBooked ? null : () {
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
    List<MentorService> selectedServicesList = selectedServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedDate != null && selectedTimeSlot != null && selectedServicesList.isNotEmpty) {
      try {
        Connection connection = await Connection.open(
          Endpoint(
            host: '34.71.87.187',
            port: 5432,
            database: 'datagovernance',
            username: 'postgres',
            password: 'India@5555',
          ),
          settings: const ConnectionSettings(sslMode: SslMode.disable),
        );

        for (var service in selectedServicesList) {
          await connection.execute(Sql.named('INSERT INTO appointments (advisor_id, service_id, date, time) VALUES (@advisorId, @serviceId, @date, @time)'),
            parameters: {
              'advisorId': widget.masterDetails.shopID,
              'serviceId': service.shopId,
              'date': selectedDate,
              'time': selectedTimeSlot,
            },
          );
        }

        await connection.close();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Appointment Confirmed'),
              content: Text('Your appointment is confirmed for ${selectedDate!.toLocal().toString().split(' ')[0]} at $selectedTimeSlot.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Go back to the previous screen
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Failed to confirm appointment: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to confirm appointment. Please try again.'),
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
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Incomplete Selection'),
            content: const Text('Please select a date, time slot, and at least one service.'),
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
    }
  }
}
