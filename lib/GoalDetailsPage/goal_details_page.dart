import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:passionHub/Models/progress_tracking.dart'; // Import your ProgressTracking model
import 'package:passionHub/Services/database_service.dart'; // Import your DatabaseService

class GoalDetailsPage extends StatelessWidget {
  final int userId; // Assuming you have userId available
  final int advisorId; // Assuming you have advisorId available

  const GoalDetailsPage(
      {super.key, required this.userId, required this.advisorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<String>>(
              future: _fetchGoalTypes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Colors.blue);
                } else if (snapshot.hasError) {
                  return Text('Error fetching goal types: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snapshot.data!.map((goalType) =>
                        _buildGoalTypeTile(goalType)).toList(),
                  );
                } else {
                  return const Text('No goal types found.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _fetchGoalTypes() async {
    try {
      DatabaseService dbService = DatabaseService();
      return await dbService.getDistinctGoalTypes(userId, advisorId) ;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching goal types: $e');
      }
      return []; // Return an empty list on error
    }
  }

  Widget _buildGoalTypeTile(String goalType) {
    return ExpansionTile(
      title: Text(goalType),
      children: [
        FutureBuilder<List<ProgressTracking>>(
          future: _fetchProgressTracking(goalType),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: Colors.blue);
            } else if (snapshot.hasError) {
              return Text(
                  'Error fetching progress tracking: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.map((progress) =>
                    _buildProgressTile(progress)).toList(),
              );
            } else {
              return const Text(
                  'No progress tracking found for this goal type.');
            }
          },
        ),
      ],
    );
  }

  Future<List<ProgressTracking>> _fetchProgressTracking(String goalType) async {
    try {
      DatabaseService dbService = DatabaseService();
      return await dbService.getProgressDetailsByGoalType(
          userId, advisorId, goalType) ;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching progress tracking: $e');
      }
      return []; // Return an empty list on error
    }
  }

  Widget _buildProgressTile(ProgressTracking progress) {
    final formattedProgressDate = DateFormat('yyyy-MM-dd').format(
        progress.progressDate);
    return ListTile(
      title: Text('Goal: ${progress.goal}'),
      subtitle:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Action Steps: ${progress.actionSteps}',),
          Text('Progress Date: $formattedProgressDate'),
          Text('Progress Made: ${progress.progressMade}'),
          Text('Outcome: ${progress.outcome}'),
          Text('Next Steps: ${progress.nextSteps}'),
          Text('Agenda: ${progress.agenda}'),
          Text('Additional Steps: ${progress.additionalNotes}'),
        ],
      ),
      // Display additional progress details as needed
    );
  }
}