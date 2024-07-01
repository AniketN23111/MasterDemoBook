import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:saloon/Models/mentor_details.dart';

class DetailPage extends StatefulWidget {
  final MentorDetails masterDetails;

  const DetailPage({Key? key, required this.masterDetails}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<String> parseTimeSlots(String timeSlots) {
    // Remove the brackets and split by comma to get individual slots
    return timeSlots.substring(1, timeSlots.length - 1).split(',').map((s) => s.trim()).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<bool> workingDaysList = parseWorkingDays(widget.masterDetails.workingDays);
    List<String> daysOfWeek = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    List<String> timeSlots = parseTimeSlots(widget.masterDetails.timeSlots);

    // Parse services
    List<String> services = widget.masterDetails.services.split(',');

    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
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
                child: widget.masterDetails.imageURl != null
                    ? Image.network(widget.masterDetails.imageURl, height: 200, width: 200, fit: BoxFit.cover)
                    : Container(height: 200, width: 200, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16.0),
            // Shop Basic Details
            _buildDetailItem(Icons.person, 'Name', widget.masterDetails.name),
            _buildDetailItem(Icons.location_on, 'Address', widget.masterDetails.address),
            _buildDetailItem(Icons.phone, 'Mobile', widget.masterDetails.mobile),
            _buildDetailItem(Icons.email, 'Email', widget.masterDetails.email),
            _buildDetailItem(Icons.pin_drop, 'Pincode', widget.masterDetails.pincode),
            _buildDetailItem(Icons.flag, 'Country', widget.masterDetails.country),
            _buildDetailItem(Icons.map, 'State', widget.masterDetails.state),
            _buildDetailItem(Icons.location_city, 'City', widget.masterDetails.city),
            _buildDetailItem(Icons.location_on, 'Area', widget.masterDetails.area),
            _buildDetailItem(Icons.lock, 'License', widget.masterDetails.license),
            const SizedBox(height: 8.0),
            Text('Working Days:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (index) {
                return Text(
                  '${daysOfWeek[index]}: ${workingDaysList[index] ? 'Open' : 'Closed'}',
                  style: TextStyle(fontSize: 18),
                );
              }),
            ),
            const SizedBox(height: 16.0),
            Text('Time Slots:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Column(
              children: [
                ...timeSlots.asMap().entries.map((entry) {
                  int index = entry.key;
                  String slot = entry.value;
                  return ListTile(
                    title: Text('Slot ${index + 1}: $slot'),
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 16.0),
            Text('Services:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: services.map((service) {
                return Text(
                  service.trim(),
                  style: TextStyle(fontSize: 18),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<bool> parseWorkingDays(String workingDays) {
    List<dynamic> parsedList = jsonDecode(workingDays);
    return parsedList.map((e) => e as bool).toList();
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 30.0),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4.0),
                Text(value, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
