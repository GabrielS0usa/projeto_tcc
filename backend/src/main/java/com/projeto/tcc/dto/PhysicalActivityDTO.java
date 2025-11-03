package com.projeto.tcc.dto;

import java.time.LocalDateTime;

import com.projeto.tcc.entities.PhysicalActivityEntity;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

public record PhysicalActivityDTO(
    Long id,
    
    @NotBlank(message = "Activity type is required")
    String activityType,
    
    @NotBlank(message = "Activity name is required")
    String activityName,
    
    @NotNull(message = "Date is required")
    LocalDateTime date,
    
    @NotNull(message = "Duration is required")
    @PositiveOrZero(message = "Duration must be positive or zero")
    Integer durationMinutes,
    
    @NotNull(message = "Calories burned is required")
    @PositiveOrZero(message = "Calories must be positive or zero")
    Integer caloriesBurned,
    
    String notes,
    
    @NotNull(message = "Intensity level is required")
    @Min(value = 1, message = "Intensity level must be between 1 and 5")
    @Max(value = 5, message = "Intensity level must be between 1 and 5")
    Integer intensityLevel
) {
    public PhysicalActivityDTO(PhysicalActivityEntity entity) {
        this(
            entity.getId(),
            entity.getActivityType(),
            entity.getActivityName(),
            entity.getDate(),
            entity.getDurationMinutes(),
            entity.getCaloriesBurned(),
            entity.getNotes(),
            entity.getIntensityLevel()
        );
    }
}
