import 'package:flutter/material.dart';
import 'package:frontend/features/calender/state/calender_provier.dart';
import 'package:provider/provider.dart';


class CalendarHeader extends StatelessWidget {
  const CalendarHeader({super.key});

  String _getMonthName(int month) => [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ][month - 1];

  @override
  Widget build(BuildContext context) {
    final currentDate = context.watch<CalendarProvider>().currentDate;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_getMonthName(currentDate.month)} ${currentDate.year}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => context.read<CalendarProvider>().goToPreviousMonth(),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onPressed: () => context.read<CalendarProvider>().goToNextMonth(),
            ),
          ],
        ),
      ],
    );
  }
}