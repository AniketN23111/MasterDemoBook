import 'dart:convert';
import 'package:flutter/material.dart';
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
                child: widget.masterDetails.imageURL != null
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
            _buildTimeSlotsSection(timeSlots),
            const SizedBox(height: 16.0),
            // Services
            _buildServicesSection(services),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildWorkingDaysTable(List<bool> workingDaysList, List<String> daysOfWeek) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Working Days:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Table(
          border: TableBorder.all(),
          children: daysOfWeek.map((day) {
            int index = daysOfWeek.indexOf(day);
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(day, style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(workingDaysList[index] ? 'Open' : 'Closed', style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSlotsSection(List<String> timeSlots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time Slots:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Column(
          children: timeSlots.asMap().entries.map((entry) {
            int index = entry.key;
            String slot = entry.value;
            return ListTile(
              title: Text('Slot ${index + 1}: $slot'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServicesSection(List<MentorService> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Services:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: services.map((service) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${service.mainService} - ${service.subService}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 4),
                Text('Rate: ${service.rate}', style: TextStyle(fontSize: 16)),
                Text('Quantity: ${service.quantity}', style: TextStyle(fontSize: 16)),
                Text('Unit: ${service.unitMeasurement}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
