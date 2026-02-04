// lib/features/calendar/ui/widgets/calendar_grid.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/calender/state/calender_provier.dart';
import 'package:frontend/features/calender/ui/widgets/day_call.dart';
import 'package:frontend/features/calender/ui/widgets/weekday_labels.dart';
import 'package:provider/provider.dart';


class CalendarGrid extends StatelessWidget {
  const CalendarGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final currentDate = provider.currentDate;
    final selectedDate = provider.selectedDate;

    // Calculate days for the calendar grid
    final days = _buildDaysList(currentDate, selectedDate, provider);

    return Column(
      children: [
        const WeekdayLabels(),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          childAspectRatio: 1.1,
          children: days,
        ),
      ],
    );
  }

  List<Widget> _buildDaysList(
    DateTime currentDate,
    DateTime selectedDate,
    CalendarProvider provider,
  ) {
    final daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final startingDay = firstDayOfMonth.weekday % 7; // 0=Sun, 1=Mon...6=Sat

    final List<Widget> days = [];

    // Previous month days (grayed out)
    if (startingDay > 0) {
      final prevMonthYear = currentDate.month == 1 ? currentDate.year - 1 : currentDate.year;
      final prevMonth = currentDate.month == 1 ? 12 : currentDate.month - 1;
      final daysInPrevMonth = DateTime(prevMonthYear, prevMonth + 1, 0).day;
      
      for (int i = 0; i < startingDay; i++) {
        final day = daysInPrevMonth - startingDay + i + 1;
        final date = DateTime(prevMonthYear, prevMonth, day);
        days.add(_buildDayCell(date, currentDate, selectedDate, provider));
      }
    }

    // Current month days
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(currentDate.year, currentDate.month, i);
      days.add(_buildDayCell(date, currentDate, selectedDate, provider));
    }

    // Next month days (fill to 6 weeks = 42 cells max)
    final totalCells = 42;
    while (days.length < totalCells) {
      final nextMonthYear = currentDate.month == 12 ? currentDate.year + 1 : currentDate.year;
      final nextMonth = currentDate.month == 12 ? 1 : currentDate.month + 1;
      final day = days.length - startingDay - daysInMonth + 1;
      final date = DateTime(nextMonthYear, nextMonth, day);
      days.add(_buildDayCell(date, currentDate, selectedDate, provider));
    }

    return days;
  }

  Widget _buildDayCell(
    DateTime date,
    DateTime currentDateView,
    DateTime selectedDate,
    CalendarProvider provider,
  ) {
    final isCurrentMonth = date.month == currentDateView.month && 
                           date.year == currentDateView.year;
    final isSelected = date.year == selectedDate.year &&
                       date.month == selectedDate.month &&
                       date.day == selectedDate.day;
    final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;
    final taskCount = provider.getTaskCountForDate(date);

    return DayCell(
      date: date,
      isCurrentMonth: isCurrentMonth,
      isSelected: isSelected,
      isToday: isToday,
      taskCount: taskCount,
    );
  }
}