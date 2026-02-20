import 'package:flutter/material.dart';
import 'package:frontend/features/stats/state/stats_provoder.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/colors.dart';
// import 'package:frontend/features/stats/state/stats_provider.dart';
import 'package:frontend/features/stats/ui/widgets/progress_circle.dart';
import 'package:frontend/features/stats/ui/widgets/stats_card.dart';
import 'package:frontend/features/stats/ui/widgets/stats_header.dart';
import 'package:frontend/features/stats/ui/widgets/weekly_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure stats are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StatsProvider>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Productivity Statistics',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Stats Header
              const StatsHeader(
                title: 'This Week',
                subtitle: 'Your productivity this week compared to last week',
              ),
              const SizedBox(height: 24),
              
              // Progress Circle
              ProgressCircle(
                percent: context.watch<StatsProvider>().dailyGoalPercent,
                title: 'Daily Goal',
                // subtitle: 'You\'ve completed ${context.watch<StatsProvider>().todayCompleted} of ${context.watch<StatsProvider>().todayTotal} tasks today.',
              ),
              const SizedBox(height: 24),
              
              // Insight
              _buildInsightCard(context),
              const SizedBox(height: 24),
              
              // Weekly Overview
              WeeklyChart(
                weeklyOverview: context.watch<StatsProvider>().weeklyOverview,
              ),
              const SizedBox(height: 24),
              
              // Stats Grid
              _buildStatsGrid(context),
              
              // Detailed history
              // _buildDetailedHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context) {
    final provider = context.watch<StatsProvider>();
    final isPositive = provider.insightPercent > 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPositive 
            ? Colors.green.withOpacity(0.1) 
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insight',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  'You are ${provider.insightPercent.abs()}% ${isPositive ? 'more' : 'less'} productive than last week!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildStatsGrid(BuildContext context) {
  final stats = context.watch<StatsProvider>().statsDetails;
  
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StatsCard(
            title: 'TOTAL DONE',
            value: stats.totalDone.toString(),
            icon: Icons.check_circle,
            iconColor: AppColors.primary,
            isPrimary: true,
          ),
          StatsCard(
            title: 'BEST DAY',
            // ✅ HANDLE BEST DAY OBJECT
            value: stats.bestDay?.day.split(' ')[0] ?? 'N/A', 
            icon: Icons.calendar_today,
            iconColor: Colors.amber,
            isPrimary: true,
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StatsCard(
            title: 'STREAK',
            value: '${stats.streak} Days',
            icon: Icons.whatshot,
            iconColor: Colors.red,
          ),
          StatsCard(
            title: 'AVG/DAY',
            value: stats.avgPerDay.toStringAsFixed(1),
            icon: Icons.bar_chart,
            iconColor: AppColors.primary,
          ),
        ],
      ),
    ],
  );
}

  // Widget _buildDetailedHistory() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 24),
  //     child: TextButton(
  //       onPressed: () {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Detailed history feature coming soon!'),
  //           ),
  //         );
  //       },
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Text(
  //             'View detailed history',
  //             style: TextStyle(
  //               color: Colors.blue,
  //               fontSize: 16,
  //             ),
  //           ),
  //           const Icon(
  //             Icons.arrow_forward,
  //             color: Colors.blue,
  //             size: 16,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}