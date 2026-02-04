// lib/features/calendar/ui/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/features/calender/state/calender_provier.dart';
import 'package:frontend/features/calender/ui/widgets/calender_grid.dart';
import 'package:frontend/features/calender/ui/widgets/calender_header.dart';
import 'package:frontend/features/calender/ui/widgets/date_details.dart';
import 'package:provider/provider.dart';


class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.read<CalendarProvider>().goToToday(),
            style: TextButton.styleFrom(
              backgroundColor:  AppColors.primary.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child:  Text(
              'Today',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const CalendarHeader(),
            const SizedBox(height: 16),
            const CalendarGrid(), 
            const SizedBox(height: 24),
            const Expanded(child: DateDetails()),
          ],
        ),
      ),

    );
  }
}