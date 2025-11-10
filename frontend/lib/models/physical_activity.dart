import 'package:flutter/material.dart';

enum PhysicalActivityType { walking, running, cycling, swimming, yoga, other }

// Walking Session Model
class WalkingSession {
  final String? id;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final double distanceKm;
  final int steps;
  final int caloriesBurned;
  final String? notes;
  final bool isActive;

  WalkingSession({
    this.id,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.distanceKm,
    required this.steps,
    required this.caloriesBurned,
    this.notes,
    this.isActive = false,
  });

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  String get formattedDistance {
    return '${distanceKm.toStringAsFixed(2)} km';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'distanceKm': distanceKm,
      'steps': steps,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
      'isActive': isActive,
    };
  }

  factory WalkingSession.fromJson(Map<String, dynamic> json) {
    return WalkingSession(
      id: json['id']?.toString(),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      durationMinutes: json['durationMinutes'] ?? 0,
      distanceKm: (json['distanceKm'] ?? 0.0).toDouble(),
      steps: json['steps'] ?? 0,
      caloriesBurned: json['caloriesBurned'] ?? 0,
      notes: json['notes'],
      isActive: json['isActive'] ?? false,
    );
  }

  WalkingSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    double? distanceKm,
    int? steps,
    int? caloriesBurned,
    String? notes,
    bool? isActive,
  }) {
    return WalkingSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      steps: steps ?? this.steps,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Manual Physical Activity Model
class PhysicalActivity {
  final String? id;
  final PhysicalActivityType type;
  final String activityName;
  final DateTime date;
  final int durationMinutes;
  final int caloriesBurned;
  final String? notes;
  final int intensityLevel; // 1-5 scale

  PhysicalActivity({
    this.id,
    required this.type,
    required this.activityName,
    required this.date,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.notes,
    this.intensityLevel = 3,
  });

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  IconData get activityIcon {
    switch (type) {
      case PhysicalActivityType.walking:
        return Icons.directions_walk;
      case PhysicalActivityType.running:
        return Icons.directions_run;
      case PhysicalActivityType.cycling:
        return Icons.directions_bike;
      case PhysicalActivityType.swimming:
        return Icons.pool;
      case PhysicalActivityType.yoga:
        return Icons.self_improvement;
      case PhysicalActivityType.other:
        return Icons.fitness_center;
    }
  }

  Color get intensityColor {
    switch (intensityLevel) {
      case 1:
        return const Color(0xFF4CAF50); // Light green
      case 2:
        return const Color(0xFF8BC34A); // Green
      case 3:
        return const Color(0xFFF7B300); // Yellow
      case 4:
        return const Color(0xFFFF9800); // Orange
      case 5:
        return const Color(0xFFDC411E); // Red
      default:
        return const Color(0xFF9E9E9E); // Gray
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'activityName': activityName,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
      'intensityLevel': intensityLevel,
    };
  }

  factory PhysicalActivity.fromJson(Map<String, dynamic> json) {
    PhysicalActivityType type = PhysicalActivityType.other;
    try {
      type = PhysicalActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PhysicalActivityType.other,
      );
    } catch (e) {
      type = PhysicalActivityType.other;
    }

    return PhysicalActivity(
      id: json['id']?.toString(),
      type: type,
      activityName: json['activityName'] ?? '',
      date: DateTime.parse(json['date']),
      durationMinutes: json['durationMinutes'] ?? 0,
      caloriesBurned: json['caloriesBurned'] ?? 0,
      notes: json['notes'],
      intensityLevel: json['intensityLevel'] ?? 3,
    );
  }
}

// Daily Exercise Goal Model
class DailyExerciseGoal {
  final int targetSteps;
  final int targetMinutes;
  final int targetCalories;
  final int currentSteps;
  final int currentMinutes;
  final int currentCalories;

  DailyExerciseGoal({
    required this.targetSteps,
    required this.targetMinutes,
    required this.targetCalories,
    required this.currentSteps,
    required this.currentMinutes,
    required this.currentCalories,
  });

  double get stepsProgress {
    if (targetSteps == 0) return 0.0;
    return (currentSteps / targetSteps * 100).clamp(0.0, 100.0);
  }

  double get minutesProgress {
    if (targetMinutes == 0) return 0.0;
    return (currentMinutes / targetMinutes * 100).clamp(0.0, 100.0);
  }

  double get caloriesProgress {
    if (targetCalories == 0) return 0.0;
    return (currentCalories / targetCalories * 100).clamp(0.0, 100.0);
  }

  double get overallProgress {
    return (stepsProgress + minutesProgress + caloriesProgress) / 3;
  }

  bool get isGoalMet {
    return currentSteps >= targetSteps &&
           currentMinutes >= targetMinutes &&
           currentCalories >= targetCalories;
  }

  factory DailyExerciseGoal.defaultGoal() {
    return DailyExerciseGoal(
      targetSteps: 5000,
      targetMinutes: 30,
      targetCalories: 200,
      currentSteps: 0,
      currentMinutes: 0,
      currentCalories: 0,
    );
  }

  factory DailyExerciseGoal.fromJson(Map<String, dynamic> json) {
    return DailyExerciseGoal(
      targetSteps: json['targetSteps'] ?? 5000,
      targetMinutes: json['targetMinutes'] ?? 30,
      targetCalories: json['targetCalories'] ?? 200,
      currentSteps: json['currentSteps'] ?? 0,
      currentMinutes: json['currentMinutes'] ?? 0,
      currentCalories: json['currentCalories'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetSteps': targetSteps,
      'targetMinutes': targetMinutes,
      'targetCalories': targetCalories,
      'currentSteps': currentSteps,
      'currentMinutes': currentMinutes,
      'currentCalories': currentCalories,
    };
  }

  DailyExerciseGoal copyWith({
    int? targetSteps,
    int? targetMinutes,
    int? targetCalories,
    int? currentSteps,
    int? currentMinutes,
    int? currentCalories,
  }) {
    return DailyExerciseGoal(
      targetSteps: targetSteps ?? this.targetSteps,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      targetCalories: targetCalories ?? this.targetCalories,
      currentSteps: currentSteps ?? this.currentSteps,
      currentMinutes: currentMinutes ?? this.currentMinutes,
      currentCalories: currentCalories ?? this.currentCalories,
    );
  }
}

// Weekly Exercise Summary
class WeeklyExerciseSummary {
  final int totalSteps;
  final int totalMinutes;
  final int totalCalories;
  final int activeDays;
  final List<DailyExerciseGoal> dailyGoals;

  WeeklyExerciseSummary({
    required this.totalSteps,
    required this.totalMinutes,
    required this.totalCalories,
    required this.activeDays,
    required this.dailyGoals,
  });

  double get averageStepsPerDay {
    if (activeDays == 0) return 0.0;
    return totalSteps / activeDays;
  }

  factory WeeklyExerciseSummary.empty() {
    return WeeklyExerciseSummary(
      totalSteps: 0,
      totalMinutes: 0,
      totalCalories: 0,
      activeDays: 0,
      dailyGoals: [],
    );
  }

  factory WeeklyExerciseSummary.fromJson(Map<String, dynamic> json) {
    return WeeklyExerciseSummary(
      totalSteps: json['totalSteps'] ?? 0,
      totalMinutes: json['totalMinutes'] ?? 0,
      totalCalories: json['totalCalories'] ?? 0,
      activeDays: json['activeDays'] ?? 0,
      dailyGoals: (json['dailyGoals'] as List<dynamic>?)
              ?.map((e) => DailyExerciseGoal.fromJson(e))
              .toList() ??
          [],
    );
  }
}
