package com.projeto.tcc.dto;

import java.util.List;

public record WeeklyExerciseSummaryDTO(
    Integer totalSteps,
    Integer totalMinutes,
    Integer totalCalories,
    Integer activeDays,
    List<DailyExerciseGoalDTO> dailyGoals
) {
    public double getAverageStepsPerDay() {
        if (activeDays == 0) return 0.0;
        return (double) totalSteps / activeDays;
    }
    
    public static WeeklyExerciseSummaryDTO empty() {
        return new WeeklyExerciseSummaryDTO(0, 0, 0, 0, List.of());
    }
}
