import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/features/stats/model/stats_model.dart';

class WeeklyChart extends StatelessWidget {
  final List<WeeklyDayStats> weeklyOverview;

  const WeeklyChart({super.key, required this.weeklyOverview});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (weeklyOverview.isNotEmpty)
                Text(
                  '+${_calculateWeeklyGrowth()}%',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildChart(),
        ],
      ),
    );
  }

  int _calculateWeeklyGrowth() {
    if (weeklyOverview.length < 2) return 0;
    final prev = weeklyOverview[weeklyOverview.length - 2].count;
    final curr = weeklyOverview.last.count;
    if (prev == 0) return curr > 0 ? 100 : 0;
    return ((curr - prev) / prev * 100).toInt();
  }

  Widget _buildChart() {
    if (weeklyOverview.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No data available this week',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    final maxValue = weeklyOverview.map((d) => d.count).reduce((a, b) => a > b ? a : b);
    final today = DateTime.now().toString().split(' ')[0].substring(0, 3);

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark
          ,borderRadius: BorderRadius.circular(10)
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weeklyOverview.map((dayStat) {
              final height = maxValue > 0 ? (dayStat.count / maxValue) * 80 : 0;
              final isToday = dayStat.day.toLowerCase() == today.toLowerCase();
          
              return Column(
                children: [
                  // Bar
                  Container(
                    width: 18,
                    height: height.toDouble(),
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : AppColors.borderDark,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        dayStat.count.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Day label
                  Text(
                    dayStat.day,
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday ? AppColors.primary : Colors.grey[400],
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}