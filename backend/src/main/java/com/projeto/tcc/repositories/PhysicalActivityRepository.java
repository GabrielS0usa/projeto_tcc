package com.projeto.tcc.repositories;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.projeto.tcc.entities.PhysicalActivityEntity;
import com.projeto.tcc.entities.User;

public interface PhysicalActivityRepository extends JpaRepository<PhysicalActivityEntity, Long> {

    List<PhysicalActivityEntity> findByUserOrderByDateDesc(User user);
    
    List<PhysicalActivityEntity> findByUserAndDateBetweenOrderByDateDesc(
        User user, LocalDateTime start, LocalDateTime end);
    
    @Query("SELECT SUM(p.durationMinutes) FROM PhysicalActivityEntity p WHERE p.user = :user AND p.date >= :startDate")
    Long sumDurationByUserAndDate(User user, LocalDateTime startDate);
    
    @Query("SELECT SUM(p.caloriesBurned) FROM PhysicalActivityEntity p WHERE p.user = :user AND p.date >= :startDate")
    Long sumCaloriesByUserAndDate(User user, LocalDateTime startDate);
    
    @Query("SELECT COUNT(DISTINCT DATE(p.date)) FROM PhysicalActivityEntity p WHERE p.user = :user AND p.date >= :startDate")
    Long countActiveDaysByUserAndDate(User user, LocalDateTime startDate);
}
