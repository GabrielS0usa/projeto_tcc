package com.projeto.tcc.dto;

import java.time.LocalDate;

import com.projeto.tcc.entities.DailyExerciseGoal;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

public record DailyExerciseGoalDTO(
    Long id,
    
    @NotNull(message = "Date is required")
    LocalDate date,
    
    @NotNull(message = "Target steps is required")
    @PositiveOrZero(message = "Target steps must be positive or zero")
    Integer targetSteps,
    
    @NotNull(message = "Target minutes is required")
    @PositiveOrZero(message = "Target minutes must be positive or zero")
    Integer targetMinutes,
    
    @NotNull(message = "Target calories is required")
    @PositiveOrZero(message = "Target calories must be positive or zero")
    Integer targetCalories,
    
    @NotNull(message = "Current steps is required")
    @PositiveOrZero(message = "Current steps must be positive or zero")
    Integer currentSteps,
    
    @NotNull(message = "Current minutes is required")
    @PositiveOrZero(message = "Current minutes must be positive or zero")
    Integer currentMinutes,
    
    @NotNull(message = "Current calories is required")
    @PositiveOrZero(message = "Current calories must be positive or zero")
    Integer currentCalories
) {
    public DailyExerciseGoalDTO(DailyExerciseGoal entity) {
        this(
            entity.getId(),
            entity.getDate(),
            entity.getTargetSteps(),
            entity.getTargetMinutes(),
            entity.getTargetCalories(),
            entity.getCurrentSteps(),
            entity.getCurrentMinutes(),
            entity.getCurrentCalories()
        );
    }
    
    public double getStepsProgress() {
        if (targetSteps == 0) return 0.0;
        return Math.min((currentSteps * 100.0) / targetSteps, 100.0);
    }
    
    public double getMinutesProgress() {
        if (targetMinutes == 0) return 0.0;
        return Math.min((currentMinutes * 100.0) / targetMinutes, 100.0);
    }
    
    public double getCaloriesProgress() {
        if (targetCalories == 0) return 0.0;
        return Math.min((currentCalories * 100.0) / targetCalories, 100.0);
    }
    
    public double getOverallProgress() {
        return (getStepsProgress() + getMinutesProgress() + getCaloriesProgress()) / 3.0;
    }
    
    public boolean isGoalMet() {
        return currentSteps >= targetSteps &&
               currentMinutes >= targetMinutes &&
               currentCalories >= targetCalories;
    }
}
