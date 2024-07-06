import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
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
  TimeOfDay? selectedTime;
  Map<MentorService, bool> selectedServices = {};

  @override
  void initState() {
    super.initState();
    // Initialize selected services map with false
    for (var service in widget.masterServices) {
      selectedServices[service] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> parseTimeSlots(String timeSlots) {
      return timeSlots.substring(1, timeSlots.length - 1).split(',').map((s) => s.trim()).toList();
    }

    List<bool> parseWorkingDays(String workingDays) {
      List<dynamic> parsedList = jsonDecode(workingDays);
      return parsedList.map((e) => e as bool).toList();
    }

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
            // Time Slots
            if (selectedDate != null) _buildTimeSlotSelection(timeSlots),
            const SizedBox(height: 16.0),
            // Services
            _buildServicesTable(services),
            const SizedBox(height: 16.0),
            // Book Appointment Button
            Center(
              child: ElevatedButton(
                onPressed: () => _showDateTimePicker(context, workingDaysList),
                child: const Text('Book Appointment'),
              ),
            ),
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

  Widget _buildTimeSlotSelection(List<String> timeSlots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available Time Slots:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Column(
          children: timeSlots.map((slot) {
            return ListTile(
              title: Text(slot),
              leading: Radio(
                value: slot,
                groupValue: selectedTime,
                onChanged: (value) {
                  setState(() {
                    selectedTime = value as TimeOfDay?;
                  });
                },
              ),
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
                      value: selectedServices[service] ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          selectedServices[service] = value ?? false;
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

  void _showDateTimePicker(BuildContext context, List<bool> workingDaysList) async {
    DateTime initialDate = DateTime.now();

    // Find the next selectable date if initialDate is not selectable
    while (!workingDaysList[initialDate.weekday - 1]) {
      initialDate = initialDate.add(Duration(days: 1));
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(initialDate.year + 1),
      selectableDayPredicate: (DateTime date) {
        int dayOfWeek = date.weekday;
        if (dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday) {
          return workingDaysList[dayOfWeek - 1];
        }
        return true;
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
        });

        _saveAppointment(selectedDate!, selectedTime!);
      }
    }
  }


  Future<void> _saveAppointment(DateTime date, TimeOfDay time) async {
    late Connection connection;
    connection = await Connection.open(
      Endpoint(
        host: '34.71.87.187',
        port: 5432,
        database: 'datagovernance',
        username: 'postgres',
        password: 'India@5555',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    final formattedDate = '${date.year}-${date.month}-${date.day}';
    final formattedTime = '${time.hour}:${time.minute}:00';

    try {
      // Insert appointment into database
      for (var service in selectedServices.keys) {
        if (selectedServices[service]!) {
          await connection.execute(Sql.named(
              'INSERT INTO appointments (date, time, shop_id, main_service, sub_service) VALUES (@date, @time, @shopId, @mainService, @subService)'),
            parameters: {
              'date': formattedDate,
              'time': formattedTime,
              'shopId': widget.masterDetails.shopID,
              'mainService': service.mainService,
              'subService': service.subService,
            },
          );
        }
      }

      await connection.close();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Appointment booked successfully!'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to book appointment. Please try again later.'),
        duration: Duration(seconds: 2),
      ));
    }
  }
}
