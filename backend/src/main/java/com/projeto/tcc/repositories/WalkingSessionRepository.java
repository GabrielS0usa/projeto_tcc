package com.projeto.tcc.repositories;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.projeto.tcc.entities.User;
import com.projeto.tcc.entities.WalkingSession;

public interface WalkingSessionRepository extends JpaRepository<WalkingSession, Long> {

    List<WalkingSession> findByUserOrderByStartTimeDesc(User user);
    
    Optional<WalkingSession> findByUserAndIsActiveTrue(User user);
    
    List<WalkingSession> findByUserAndStartTimeBetweenOrderByStartTimeDesc(
        User user, LocalDateTime start, LocalDateTime end);
    
    @Query("SELECT SUM(w.steps) FROM WalkingSession w WHERE w.user = :user AND w.startTime >= :startDate")
    Long sumStepsByUserAndDate(User user, LocalDateTime startDate);
    
    @Query("SELECT SUM(w.durationMinutes) FROM WalkingSession w WHERE w.user = :user AND w.startTime >= :startDate")
    Long sumDurationByUserAndDate(User user, LocalDateTime startDate);
    
    @Query("SELECT SUM(w.caloriesBurned) FROM WalkingSession w WHERE w.user = :user AND w.startTime >= :startDate")
    Long sumCaloriesByUserAndDate(User user, LocalDateTime startDate);
}
