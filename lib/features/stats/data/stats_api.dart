import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_endpoints.dart';
import 'package:frontend/core/network/dio_client.dart';
// import 'package:frontend/features/stats/model/productivity_stats.dart';
import 'package:frontend/features/stats/model/stats_model.dart';

class StatsApi {
  final DioClient _dioClient;

  StatsApi(this._dioClient);

Future<ProductivityStats> getStats() async {
  try {
    final response = await _dioClient.dio.get(ApiEndpoints.productivityStats);
    print('Stats API response: ${response.data}');
    
    // Calculate insight percentage dynamically if needed
    final stats = ProductivityStats.fromJson(response.data);
    return _calculateInsight(stats); // ✅ SEE BELOW
    
  } on DioException catch (e) {
    print('Stats API error: ${e.message}');
    return _getDefaultStats();
  } catch (e) {
    print('Unexpected stats error: $e');
    return _getDefaultStats();
  }
}

// ✅ CALCULATE INSIGHT PERCENTAGE BASED ON ACTUAL DATA
ProductivityStats _calculateInsight(ProductivityStats stats) {
  // Example logic: Compare today's completion vs average
  if (stats.stats.avgPerDay > 0 && stats.todayTotal > 0) {
    final todayCompletionRate = stats.todayCompleted / stats.todayTotal;
    final avgCompletionRate = stats.stats.avgPerDay / stats.todayTotal;
    
    final insight = ((todayCompletionRate - avgCompletionRate) / avgCompletionRate * 100)
        .toInt()
        .clamp(-100, 100);
    
    return ProductivityStats(
      dailyGoalPercent: stats.dailyGoalPercent,
      todayCompleted: stats.todayCompleted,
      todayTotal: stats.todayTotal,
      insightPercent: insight, // ✅ DYNAMIC CALCULATION
      weeklyOverview: stats.weeklyOverview,
      stats: stats.stats,
    );
  }
  return stats; // Keep original if can't calculate
}

ProductivityStats _getDefaultStats() {
  return ProductivityStats(
    dailyGoalPercent: 0,
    todayCompleted: 0,
    todayTotal: 2,
    insightPercent: 0, // ✅ Default to 0
    weeklyOverview: [],
    stats: StatsDetails(
      totalDone: 0,
      bestDay: null,
      streak: 0,
      avgPerDay: 0,
    ),
  );
}
}