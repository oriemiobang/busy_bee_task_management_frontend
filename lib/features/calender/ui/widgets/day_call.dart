// lib/features/calendar/ui/widgets/day_cell.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/features/calender/state/calender_provier.dart';
import 'package:provider/provider.dart';


class DayCell extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isToday;
  final int taskCount;

  const DayCell({
    super.key,
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isToday,
    required this.taskCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleDateTap(context),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getBackgroundColor(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number with proper styling
            Text(
              date.day.toString(),
              style: TextStyle(
                color: _getTextColor(),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            // Task dots indicator (only for current month days)
            if (taskCount > 0 && isCurrentMonth) ...[
              const SizedBox(height: 4),
              _buildTaskDots(taskCount),
            ],
          ],
        ),
      ),
    );
  }

  void _handleDateTap(BuildContext context) {
    // Only allow selection of current month days (better UX)
    if (isCurrentMonth) {
      context.read<CalendarProvider>().selectDate(date);
    } else {
      // Navigate to the month of the clicked day
      context.read<CalendarProvider>().selectDate(date);
    }
  }

  Color? _getBackgroundColor() {
    if (isSelected) return AppColors.primary;
    if (isToday && isCurrentMonth) return Colors.blue.withOpacity(0.2);
    return Colors.transparent;
  }

  Color _getTextColor() {
    if (isSelected) return Colors.white;
    if (isToday && isCurrentMonth) return AppColors.primary;
    if (!isCurrentMonth) return Colors.grey[600]!;
    return Colors.grey[300]!;
  }

  Widget _buildTaskDots(int count) {
    final dots = <Widget>[];
    final maxVisible = 3;
    final visibleCount = count > maxVisible ? maxVisible : count;

    for (int i = 0; i < visibleCount; i++) {
      final isGray = count > maxVisible && i == visibleCount - 1;
      dots.add(Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
          color: isGray ? Colors.grey[600] : AppColors.primary.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: dots);
  }
}