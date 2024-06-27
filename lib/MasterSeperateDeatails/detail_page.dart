import 'package:flutter/material.dart';
import 'package:saloon/Models/master_details.dart';

class DetailPage extends StatelessWidget {
  final MasterDetails masterDetails;

  const DetailPage({super.key, required this.masterDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(masterDetails.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${masterDetails.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            Text('Address: ${masterDetails.address}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            Text('Mobile: ${masterDetails.mobile}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            Text('Email: ${masterDetails.email}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            Text('Pincode: ${masterDetails.pincode}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            Text('Country: ${masterDetails.country}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            Text('State: ${masterDetails.state}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            Text('City: ${masterDetails.city}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            Text('Area: ${masterDetails.area}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            Text('License: ${masterDetails.license}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            Text('Working Days: ${masterDetails.workingDays}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
