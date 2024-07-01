import 'package:flutter/material.dart';
import 'package:saloon/HomeScreen/SearchPage.dart';
import 'package:saloon/MasterSeperateDeatails/separate_mentor_details.dart';
import 'package:saloon/Services/database_service.dart';
import 'package:saloon/Models/mentor_details.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userFirstName = ''; // Variable to hold the user's first name
  List<MentorDetails> masterDetailsList = [];

  @override
  void initState() {
    super.initState();
    _fetchMasterDetails();
  }

  void _fetchMasterDetails() async {
    DatabaseService dbService = DatabaseService();
    List<MentorDetails> details = await dbService.getMentorDetails();
    setState(() {
      masterDetailsList = details;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.blue, // Blue container
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Hello, $userFirstName!', // Display the user's first name
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for a Service',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPage(), // Navigate to the SearchPage
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              // Container for the list view of images
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: masterDetailsList.length,
                itemBuilder: (BuildContext context, int index) {
                  final masterDetails = masterDetailsList[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(masterDetails: masterDetails),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Image.network(masterDetails.imageURl, // Replace with your image URLs
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Text(masterDetails.name),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}