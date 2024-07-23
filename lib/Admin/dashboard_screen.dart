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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _dbService.getDashboardData(_selectedYear);
    setState(() {
      _dashboardData = data.cast<String, Map<int, int>>();
    });
  }

  void _onYearChanged(int year) {
    setState(() {
      _selectedYear = year;
      _loadData();
    });
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
      body: _dashboardData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            for (var mentorName in _dashboardData!.keys)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentorName,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 10),
                    Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FractionColumnWidth(0.3),
                        1: FractionColumnWidth(0.7),
                      },
                      children: [
                        const TableRow(
                          children: [
                            Center(child: Text('Month')),
                            Center(child: Text('Number of Meetings')),
                          ],
                        ),
                        for (var month in List.generate(12, (index) => index + 1))
                          TableRow(
                            children: [
                              Center(child: Text(DateFormat('MMMM').format(DateTime(0, month)))),
                              Center(child: Text('${_dashboardData![mentorName]![month] ?? 0}')),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<int?> showYearPicker(BuildContext context, int currentYear) async {
    final year = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: YearPicker(
            selectedDate: DateTime(currentYear),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onChanged: (DateTime dateTime) {
              Navigator.of(context).pop(dateTime.year);
            },
          ),
        );
      },
    );
    return year;
  }
}
