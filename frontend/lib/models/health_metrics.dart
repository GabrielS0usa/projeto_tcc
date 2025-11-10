// lib/models/health_metrics.dart

class HealthMetrics {
  final int completedTasks;
  final int totalTasks;
  final DateTime date;
  final Map<String, bool> taskStatus;

  HealthMetrics({
    required this.completedTasks,
    required this.totalTasks,
    required this.date,
    required this.taskStatus,
  });

  // Calculate progress percentage
  double get progressPercentage {
    if (totalTasks == 0) return 0.0;
    return (completedTasks / totalTasks);
  }

  // Get progress text
  String get progressText => '$completedTasks / $totalTasks';

  // Check if all tasks are completed
  bool get isAllCompleted => completedTasks == totalTasks;

  // Factory constructor for creating mock/default metrics
  factory HealthMetrics.mock() {
    return HealthMetrics(
      completedTasks: 18,
      totalTasks: 20,
      date: DateTime.now(),
      taskStatus: {
        'wellness_diary': true,
        'health_management': true,
        'mental_activity': false,
        'exercise': true,
        'nutrition': true,
        'medicine': true,
      },
    );
  }

  // Factory constructor from JSON (for future API integration)
  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      completedTasks: json['completedTasks'] as int,
      totalTasks: json['totalTasks'] as int,
      date: DateTime.parse(json['date'] as String),
      taskStatus: Map<String, bool>.from(json['taskStatus'] as Map),
    );
  }

  // Convert to JSON (for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'date': date.toIso8601String(),
      'taskStatus': taskStatus,
    };
  }

  // Copy with method for immutable updates
  HealthMetrics copyWith({
    int? completedTasks,
    int? totalTasks,
    DateTime? date,
    Map<String, bool>? taskStatus,
  }) {
    return HealthMetrics(
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      date: date ?? this.date,
      taskStatus: taskStatus ?? this.taskStatus,
    );
  }

  // Update task status
  HealthMetrics updateTaskStatus(String taskKey, bool completed) {
    final newTaskStatus = Map<String, bool>.from(taskStatus);
    final wasCompleted = newTaskStatus[taskKey] ?? false;
    newTaskStatus[taskKey] = completed;

    int newCompletedCount = completedTasks;
    if (completed && !wasCompleted) {
      newCompletedCount++;
    } else if (!completed && wasCompleted) {
      newCompletedCount--;
    }

    return copyWith(
      completedTasks: newCompletedCount,
      taskStatus: newTaskStatus,
    );
  }
}
