// lib/features/calendar/ui/widgets/date_details.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/calender/state/calender_provier.dart';
import 'package:frontend/features/calender/ui/widgets/empty_state.dart';
import 'package:frontend/features/dashboard/ui/widgets/task_card.dart';
import 'package:provider/provider.dart';


class DateDetails extends StatelessWidget {
  const DateDetails({super.key});

  String _getDayName(int weekday) => [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ][weekday - 1]; // Dart weekday: 1=Mon, 7=Sun

  String _getMonthName(int month) => [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ][month - 1];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final selectedDate = provider.selectedDate;
    final tasks = provider.tasksForSelectedDate;
    final isLoading = provider.isLoading;
    final error = provider.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header with task count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_getDayName(selectedDate.weekday)}, ${_getMonthName(selectedDate.month)} ${selectedDate.day}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${tasks.length} Tasks',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Loading state
        if (isLoading && tasks.isEmpty)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        // Error state
        else if (error != null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: $error', style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.selectDate(selectedDate), // Refresh
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        // Empty state
        else if (tasks.isEmpty)
          const Expanded(
            child: Center(
              child: EmptyState(
                message: 'No tasks scheduled',
                subMessage: 'Tap + to create your first task',
              ),
            ),
          )
        // Task list
        else
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) => TaskCard(task: tasks[index], onTaskToggle: () {  }, onSubTaskToggle: (int subTaskId) {  }, isHome: false,),
            ),
          ),
      ],
    );
  }
}