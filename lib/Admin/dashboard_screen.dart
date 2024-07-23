import 'package:flutter/material.dart';
import '../Services/database_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _dbService = DatabaseService(/* your connection */);
  int _selectedYear = DateTime.now().year;
  Map<String, Map<int, int>>? _dashboardData;
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
    final data = await _dbService.getDashboardData(_selectedYear);
    setState(() {
      _dashboardData = data.cast<String, Map<int, int>>();
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
        title: const Text('Mentor Dashboard'),
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
          : _dashboardData == null || _dashboardData!.isEmpty
          ? const Center(child: Text('No meetings'))
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table header with month names
            Table(
              border: TableBorder.all(),
              columnWidths: {
                0: FixedColumnWidth(150), // Width for mentor names
                for (int month = 1; month <= 12; month++)
                  month: FixedColumnWidth(70), // Width for each month
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
                for (var mentorName in _dashboardData!.keys)
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
                            child: Text('${_dashboardData![mentorName]![month] ?? 0}'),
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