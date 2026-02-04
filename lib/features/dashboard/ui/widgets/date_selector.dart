import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final weekDays = List.generate(7, (index) {
      final now = DateTime.now();
      final date = now.add(Duration(days: index));
      final day = DateFormat('EEE').format(date);
      return '$day ${date.day}';
    });

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (_, index) {
          final today = DateTime.now();
          final date = today.add(Duration(days: index));
          final isToday = date.day == today.day;
          final parts = weekDays[index].split(' ');

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isToday ? AppColors.primary : AppColors.surfaceDark,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(parts[0], style: const TextStyle(fontSize: 12)),
                  Text(parts[1],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}