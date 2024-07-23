import 'package:flutter/material.dart';
import '../Services/database_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _dbService = DatabaseService();
  int _selectedYear = DateTime.now().year;
  Map<String, Map<int, int>>? _MentorData;
  Map<String, Map<int, int>>? _MenteeData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final mentorData = await _dbService.getMentorMeetingCounts(_selectedYear);
    final menteeData = await _dbService.getMenteeMeetingCounts(_selectedYear);
    setState(() {
      _MentorData = mentorData.cast<String, Map<int, int>>();
      _MenteeData = menteeData.cast<String, Map<int, int>>();
      _isLoading = false;
    });
  }

  void _onYearChanged(int year) {
    setState(() {
      _selectedYear = year;
    });
    _loadData();
  }

  Future<int?> showYearPicker(BuildContext context, int currentYear) async {
    final year = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: YearPicker(
              selectedDate: DateTime(currentYear),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onChanged: (DateTime dateTime) {
                Navigator.of(context).pop(dateTime.year);
              },
            ),
          ),
        );
      },
    );
    return year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final year = await showYearPicker(context, _selectedYear);
              if (year != null) {
                _onYearChanged(year);
              }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _MentorData == null || _MentorData!.isEmpty || _MenteeData == null || _MenteeData!.isEmpty
          ? const Center(child: Text('No meetings'))
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mentor Meetings Table
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Mentor Meetings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: {
                0: const FixedColumnWidth(150), // Width for mentor names
                for (int month = 1; month <= 12; month++)
                  month: const FixedColumnWidth(70), // Width for each month
              },
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Center(
                        child: Text(
                          'Mentor Name',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    for (int month = 1; month <= 12; month++)
                      TableCell(
                        child: Center(
                          child: Text(DateFormat('MMM').format(DateTime(0, month))),
                        ),
                      ),
                  ],
                ),
                // Data rows for each mentor
                for (var mentorName in _MentorData!.keys)
                  TableRow(
                    children: [
                      TableCell(
                        child: Center(
                          child: Text(
                            mentorName,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      for (int month = 1; month <= 12; month++)
                        TableCell(
                          child: Center(
                            child: Text('${_MentorData![mentorName]![month] ?? 0}'),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            // Spacer between tables
            const SizedBox(height: 20),
            // Mentee Meetings Table
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Mentee Meetings',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: {
                0: const FixedColumnWidth(150), // Width for mentee names
                for (int month = 1; month <= 12; month++)
                  month: const FixedColumnWidth(70), // Width for each month
              },
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Center(
                        child: Text(
                          'Mentee Name',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    for (int month = 1; month <= 12; month++)
                      TableCell(
                        child: Center(
                          child: Text(DateFormat('MMM').format(DateTime(0, month))),
                        ),
                      ),
                  ],
                ),
                // Data rows for each mentee
                for (var menteeName in _MenteeData!.keys)
                  TableRow(
                    children: [
                      TableCell(
                        child: Center(
                          child: Text(
                            menteeName,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      for (int month = 1; month <= 12; month++)
                        TableCell(
                          child: Center(
                            child: Text('${_MenteeData![menteeName]![month] ?? 0}'),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
