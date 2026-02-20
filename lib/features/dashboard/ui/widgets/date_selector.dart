import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    // 1️ Find the Monday of this week
    final monday = today.subtract(Duration(days: today.weekday - 1));

    // 2️ Generate 7 days starting from Monday
    final weekDays = List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      final day = DateFormat('EEE').format(date); // Mon, Tue, ...
      return {'date': date, 'label': '$day ${date.day}'};
    });

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (_, index) {
          final date = weekDays[index]['date'] as DateTime;
          final label = weekDays[index]['label'] as String;
          final isToday = date.day == today.day &&
              date.month == today.month &&
              date.year == today.year;

          final parts = label.split(' ');

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
