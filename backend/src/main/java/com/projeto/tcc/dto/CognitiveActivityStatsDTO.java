package com.projeto.tcc.dto;

public record CognitiveActivityStatsDTO(
    Long booksRead,
    Long crosswordsCompleted,
    Long moviesWatched,
    Long totalActivities,
    Integer weeklyStreak
) {
    public CognitiveActivityStatsDTO(Long booksRead, Long crosswordsCompleted, Long moviesWatched, Integer weeklyStreak) {
        this(
            booksRead,
            crosswordsCompleted,
            moviesWatched,
            booksRead + crosswordsCompleted + moviesWatched,
            weeklyStreak
        );
    }
}
