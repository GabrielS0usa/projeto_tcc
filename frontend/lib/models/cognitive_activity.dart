import 'package:flutter/material.dart';

enum CognitiveActivityType { reading, crosswords, movies }

class ReadingActivity {
  final String? id;
  final String bookTitle;
  final String? author;
  final int totalPages;
  final int currentPage;
  final String? notes;
  final DateTime startDate;
  final DateTime? completionDate;
  final bool isCompleted;

  ReadingActivity({
    this.id,
    required this.bookTitle,
    this.author,
    required this.totalPages,
    required this.currentPage,
    this.notes,
    required this.startDate,
    this.completionDate,
    this.isCompleted = false,
  });

  double get progressPercentage {
    if (totalPages == 0) return 0.0;
    return (currentPage / totalPages * 100).clamp(0.0, 100.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookTitle': bookTitle,
      'author': author,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'notes': notes,
      'startDate': startDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory ReadingActivity.fromJson(Map<String, dynamic> json) {
    return ReadingActivity(
      id: json['id']?.toString(),
      bookTitle: json['bookTitle'] ?? '',
      author: json['author'],
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      notes: json['notes'],
      startDate: DateTime.parse(json['startDate']),
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  ReadingActivity copyWith({
    String? id,
    String? bookTitle,
    String? author,
    int? totalPages,
    int? currentPage,
    String? notes,
    DateTime? startDate,
    DateTime? completionDate,
    bool? isCompleted,
  }) {
    return ReadingActivity(
      id: id ?? this.id,
      bookTitle: bookTitle ?? this.bookTitle,
      author: author ?? this.author,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class CrosswordActivity {
  final String? id;
  final String puzzleName;
  final String difficulty;
  final DateTime date;
  final int timeSpentMinutes;
  final bool isCompleted;
  final String? notes;

  CrosswordActivity({
    this.id,
    required this.puzzleName,
    required this.difficulty,
    required this.date,
    required this.timeSpentMinutes,
    this.isCompleted = false,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'puzzleName': puzzleName,
      'difficulty': difficulty,
      'date': date.toIso8601String(),
      'timeSpentMinutes': timeSpentMinutes,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  factory CrosswordActivity.fromJson(Map<String, dynamic> json) {
    return CrosswordActivity(
      id: json['id']?.toString(),
      puzzleName: json['puzzleName'],
      difficulty: json['difficulty'],
      date: DateTime.parse(json['date']),
      timeSpentMinutes: json['timeSpentMinutes'],
      isCompleted: json['isCompleted'],
      notes: json['notes'],
    );
  }

  Color getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFF7B300);
      case 'hard':
        return const Color(0xFFDC411E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

class MovieActivity {
  final String? id;
  final String movieTitle;
  final String? genre;
  final int rating;
  final DateTime watchDate;
  final String? review;
  final bool isWatched;

  MovieActivity({
    this.id,
    required this.movieTitle,
    this.genre,
    required this.rating,
    required this.watchDate,
    this.review,
    this.isWatched = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieTitle': movieTitle,
      'genre': genre,
      'rating': rating,
      'watchDate': watchDate.toIso8601String(),
      'review': review,
      'isWatched': isWatched,
    };
  }

  factory MovieActivity.fromJson(Map<String, dynamic> json) {
    return MovieActivity(
      id: json['id']?.toString(),
      movieTitle: json['movieTitle'] ?? '',
      genre: json['genre'],
      rating: json['rating'] ?? 3,
      watchDate: DateTime.parse(json['watchDate']),
      review: json['review'],
      isWatched: json['isWatched'] ?? true,
    );
  }
}

class CognitiveActivityStats {
  final int booksRead;
  final int crosswordsCompleted;
  final int moviesWatched;
  final int totalActivities;
  final int weeklyStreak;

  CognitiveActivityStats({
    required this.booksRead,
    required this.crosswordsCompleted,
    required this.moviesWatched,
    required this.weeklyStreak,
  }) : totalActivities = booksRead + crosswordsCompleted + moviesWatched;

  factory CognitiveActivityStats.empty() {
    return CognitiveActivityStats(
      booksRead: 0,
      crosswordsCompleted: 0,
      moviesWatched: 0,
      weeklyStreak: 0,
    );
  }

  factory CognitiveActivityStats.fromJson(Map<String, dynamic> json) {
    return CognitiveActivityStats(
      booksRead: json['booksRead'] ?? 0,
      crosswordsCompleted: json['crosswordsCompleted'] ?? 0,
      moviesWatched: json['moviesWatched'] ?? 0,
      weeklyStreak: json['weeklyStreak'] ?? 0,
    );
  }
}
