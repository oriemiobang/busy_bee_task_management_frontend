import 'package:flutter/material.dart';

class WeekdayLabels extends StatelessWidget {
  const WeekdayLabels({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final day in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
          Text(
            day,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}