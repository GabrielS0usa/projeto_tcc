// lib/models/statistics.dart

class UserStatistics {
  final StatisticsSummary summary;
  final ActivityCharts charts;
  final TrendAnalysis trends;
  final DateTime generatedAt;

  UserStatistics({
    required this.summary,
    required this.charts,
    required this.trends,
    required this.generatedAt,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      summary: StatisticsSummary.fromJson(json['summary'] as Map<String, dynamic>),
      charts: ActivityCharts.fromJson(json['charts'] as Map<String, dynamic>),
      trends: TrendAnalysis.fromJson(json['trends'] as Map<String, dynamic>),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'charts': charts.toJson(),
      'trends': trends.toJson(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

class StatisticsSummary {
  final double totalValue;
  final int totalActivities;
  final Map<String, double> averagesByType;
  final int averageQualityScore;

  StatisticsSummary({
    required this.totalValue,
    required this.totalActivities,
    required this.averagesByType,
    required this.averageQualityScore,
  });

  factory StatisticsSummary.fromJson(Map<String, dynamic> json) {
    return StatisticsSummary(
      totalValue: (json['totalValue'] as num).toDouble(),
      totalActivities: json['totalActivities'] as int,
      averagesByType: Map<String, double>.from(json['averagesByType'] as Map),
      averageQualityScore: json['averageQualityScore'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalValue': totalValue,
      'totalActivities': totalActivities,
      'averagesByType': averagesByType,
      'averageQualityScore': averageQualityScore,
    };
  }
}

class ActivityCharts {
  final Map<String, dynamic> weeklyProgress;
  final Map<String, dynamic> categoryBreakdown;
  final Map<String, dynamic> performanceMetrics;
  final Map<String, dynamic> goalTracking;

  ActivityCharts({
    required this.weeklyProgress,
    required this.categoryBreakdown,
    required this.performanceMetrics,
    required this.goalTracking,
  });

  factory ActivityCharts.fromJson(Map<String, dynamic> json) {
    return ActivityCharts(
      weeklyProgress: json['weeklyProgress'] as Map<String, dynamic>,
      categoryBreakdown: json['categoryBreakdown'] as Map<String, dynamic>,
      performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>,
      goalTracking: json['goalTracking'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklyProgress': weeklyProgress,
      'categoryBreakdown': categoryBreakdown,
      'performanceMetrics': performanceMetrics,
      'goalTracking': goalTracking,
    };
  }
}

class TrendAnalysis {
  final String period;
  final List<ActivityTrend> trends;
  final double trendSlope;
  final String trendDirection;

  TrendAnalysis({
    required this.period,
    required this.trends,
    required this.trendSlope,
    required this.trendDirection,
  });

  factory TrendAnalysis.fromJson(Map<String, dynamic> json) {
    return TrendAnalysis(
      period: json['period'] as String,
      trends: (json['trends'] as List)
          .map((item) => ActivityTrend.fromJson(item as Map<String, dynamic>))
          .toList(),
      trendSlope: (json['trendSlope'] as num).toDouble(),
      trendDirection: json['trendDirection'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'trends': trends.map((trend) => trend.toJson()).toList(),
      'trendSlope': trendSlope,
      'trendDirection': trendDirection,
    };
  }
}

class ActivityTrend {
  final DateTime date;
  final double averageValue;
  final int count;

  ActivityTrend({
    required this.date,
    required this.averageValue,
    required this.count,
  });

  factory ActivityTrend.fromJson(Map<String, dynamic> json) {
    return ActivityTrend(
      date: DateTime.parse(json['date'] as String),
      averageValue: (json['averageValue'] as num).toDouble(),
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'averageValue': averageValue,
      'count': count,
    };
  }
}

// Legacy Statistics class for backward compatibility
class Statistics {
  final int totalActivities;
  final double averageActivitiesPerDay;
  final Map<String, int> activitiesByCategory;
  final List<TrendData> weeklyTrends;
  final Map<String, double> completionRates;

  Statistics({
    required this.totalActivities,
    required this.averageActivitiesPerDay,
    required this.activitiesByCategory,
    required this.weeklyTrends,
    required this.completionRates,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalActivities: json['totalActivities'] as int,
      averageActivitiesPerDay: (json['averageActivitiesPerDay'] as num).toDouble(),
      activitiesByCategory: Map<String, int>.from(json['activitiesByCategory'] as Map),
      weeklyTrends: (json['weeklyTrends'] as List)
          .map((item) => TrendData.fromJson(item as Map<String, dynamic>))
          .toList(),
      completionRates: Map<String, double>.from(json['completionRates'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalActivities': totalActivities,
      'averageActivitiesPerDay': averageActivitiesPerDay,
      'activitiesByCategory': activitiesByCategory,
      'weeklyTrends': weeklyTrends.map((trend) => trend.toJson()).toList(),
      'completionRates': completionRates,
    };
  }
}

class TrendData {
  final String day;
  final int count;

  TrendData({
    required this.day,
    required this.count,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      day: json['day'] as String,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'count': count,
    };
  }
}
