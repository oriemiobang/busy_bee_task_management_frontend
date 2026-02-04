class ProductivityStats {
  final int dailyGoalPercent;
  final int todayCompleted;
  final int todayTotal;
  final int insightPercent;
  final List<WeeklyDayStats> weeklyOverview;
  final StatsDetails stats;

  ProductivityStats({
    required this.dailyGoalPercent,
    required this.todayCompleted,
    required this.todayTotal,
    required this.insightPercent,
    required this.weeklyOverview,
    required this.stats,
  });

  factory ProductivityStats.fromJson(Map<String, dynamic> json) {
    return ProductivityStats(
      dailyGoalPercent: (json['dailyGoalPercent'] as num?)?.toInt() ?? 0,
      todayCompleted: (json['todayCompleted'] as num?)?.toInt() ?? 0,
      todayTotal: (json['todayTotal'] as num?)?.toInt() ?? 0,
      insightPercent: (json['insightPercent'] as num?)?.toInt() ?? 0,
      weeklyOverview: (json['weeklyOverview'] as List?)
              ?.map((e) => WeeklyDayStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      stats: StatsDetails.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyGoalPercent': dailyGoalPercent,
      'todayCompleted': todayCompleted,
      'todayTotal': todayTotal,
      'insightPercent': insightPercent,
      'weeklyOverview': weeklyOverview.map((e) => e.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }
}

class WeeklyDayStats {
  final String day;
  final int count; // ✅ CHANGED FROM tasksCompleted TO count

  WeeklyDayStats({
    required this.day,
    required this.count,
  });

  factory WeeklyDayStats.fromJson(Map<String, dynamic> json) {
    return WeeklyDayStats(
      day: json['day']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0, // ✅ SAFE CASTING
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'count': count, // ✅ MATCHES BACKEND
    };
  }
}

class StatsDetails {
  final int totalDone;
  final BestDay? bestDay; // ✅ CHANGED TO OBJECT
  final int streak;
  final double avgPerDay;

  StatsDetails({
    required this.totalDone,
    this.bestDay,
    required this.streak,
    required this.avgPerDay,
  });

  factory StatsDetails.fromJson(Map<String, dynamic> json) {
    return StatsDetails(
      totalDone: (json['totalDone'] as num?)?.toInt() ?? 0,
      bestDay: json['bestDay'] != null
          ? BestDay.fromJson(json['bestDay'] as Map<String, dynamic>)
          : null,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      avgPerDay: double.tryParse(json['avgPerDay'].toString()) ?? 0.0, // ✅ SAFE PARSE
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDone': totalDone,
      'bestDay': bestDay?.toJson(),
      'streak': streak,
      'avgPerDay': avgPerDay,
    };
  }
}

class BestDay {
  final String day;
  final int count;

  BestDay({required this.day, required this.count});

  factory BestDay.fromJson(Map<String, dynamic> json) {
    return BestDay(
      day: json['day']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'count': count,
    };
  }
}