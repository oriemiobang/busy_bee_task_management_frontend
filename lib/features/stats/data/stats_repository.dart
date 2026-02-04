import 'package:frontend/core/storage/secure_storage.dart';

import 'package:frontend/features/stats/model/stats_model.dart';
import 'package:frontend/features/stats/data/stats_api.dart';

class StatsRepository {
  final StatsApi _statsApi;
  final SecureStorage _secureStorage;

  StatsRepository(this._statsApi, this._secureStorage);

  Future<ProductivityStats> getStats() async {
    try {
      // Check if we have valid cache
      final isCacheValid = await _secureStorage.isCacheValid(
        key: 'productivity_stats',
      );
      
      if (isCacheValid) {
        print('Loading stats from cache');
        final cachedStats = await _getCachedStats();
        
        if (cachedStats != null) {
          print('Loaded stats from cache');
          return cachedStats;
        }
      }
      
      // Fetch from API
      print('Fetching stats from API...');
      final stats = await _statsApi.getStats();
      
      // Cache the stats
      await _cacheStats(stats);
      
      return stats;
    } catch (e) {
      print('Error in getStats: $e');
      
      // Try to return cached data as fallback
      try {
        final cachedStats = await _getCachedStats();
        if (cachedStats != null) {
          print('Falling back to cached stats');
          return cachedStats;
        }
      } catch (cacheError) {
        print('Could not load from cache: $cacheError');
      }
      
      // Return default stats on error
      return ProductivityStats(
        dailyGoalPercent: 0,
        todayCompleted: 0,
        todayTotal: 2,
        insightPercent: 20,
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

  Future<void> _cacheStats(ProductivityStats stats) async {
    try {
      final statsJson = stats.toJson();
      await _secureStorage.cacheData(
        key: 'productivity_stats',
        data: statsJson,
        dataType: 'stats',
      );
      print('Cached productivity stats');
    } catch (e) {
      print('Error caching stats: $e');
    }
  }

  Future<ProductivityStats?> _getCachedStats() async {
    try {
      final cachedData = await _secureStorage.getCachedData(
        key: 'productivity_stats',
        dataType: 'stats',
      );
      
      if (cachedData == null) {
        return null;
      }
      
      final statsJson = cachedData as Map<String, dynamic>;
      return ProductivityStats.fromJson(statsJson);
    } catch (e) {
      print('Error reading cached stats: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      await _secureStorage.clearCacheByDataType('stats');
      print('Cleared stats cache');
    } catch (e) {
      print('Error clearing stats cache: $e');
    }
  }
}