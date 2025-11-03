package com.projeto.tcc.dto;

import java.time.LocalDateTime;

import com.projeto.tcc.entities.WalkingSession;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

public record WalkingSessionDTO(
    Long id,
    
    @NotNull(message = "Start time is required")
    LocalDateTime startTime,
    
    LocalDateTime endTime,
    
    @NotNull(message = "Duration is required")
    @PositiveOrZero(message = "Duration must be positive or zero")
    Integer durationMinutes,
    
    @NotNull(message = "Distance is required")
    @PositiveOrZero(message = "Distance must be positive or zero")
    Double distanceKm,
    
    @NotNull(message = "Steps are required")
    @PositiveOrZero(message = "Steps must be positive or zero")
    Integer steps,
    
    @NotNull(message = "Calories burned is required")
    @PositiveOrZero(message = "Calories must be positive or zero")
    Integer caloriesBurned,
    
    String notes,
    
    Boolean isActive
) {
    public WalkingSessionDTO(WalkingSession entity) {
        this(
            entity.getId(),
            entity.getStartTime(),
            entity.getEndTime(),
            entity.getDurationMinutes(),
            entity.getDistanceKm(),
            entity.getSteps(),
            entity.getCaloriesBurned(),
            entity.getNotes(),
            entity.getIsActive()
        );
    }
}
