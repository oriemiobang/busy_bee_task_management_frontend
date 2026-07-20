import 'package:flutter/foundation.dart';
import 'package:frontend/features/stats/model/stats_model.dart';
import 'package:frontend/features/stats/data/stats_repository.dart';

class StatsProvider with ChangeNotifier {
  final StatsRepository _repository;
  ProductivityStats? _stats;
  bool _isLoading = false;
  String? _error;

  StatsProvider(this._repository);

  ProductivityStats get stats => _stats ?? _getDefaultStats();
  int get dailyGoalPercent => stats.dailyGoalPercent;
  int get todayCompleted => stats.todayCompleted;
  int get todayTotal => stats.todayTotal;
  int get insightPercent => stats.insightPercent;
  List<WeeklyDayStats> get weeklyOverview => stats.weeklyOverview;
  StatsDetails get statsDetails => stats.stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductivityStats _getDefaultStats() {
    return ProductivityStats(
      dailyGoalPercent: 0,
      todayCompleted: 0,
      todayTotal: 2,
      insightPercent: 0,
      weeklyOverview: [],
      stats: StatsDetails(
        totalDone: 0,
        bestDay: null,
        streak: 0,
        avgPerDay: 0,
      ),
    );
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _repository.getStats();
    } catch (e) {
      _error = e.toString();
      _stats = null; // Force fallback to default
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}