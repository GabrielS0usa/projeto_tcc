package com.projeto.tcc.repositories;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.projeto.tcc.entities.ReadingActivity;
import com.projeto.tcc.entities.User;

public interface ReadingActivityRepository extends JpaRepository<ReadingActivity, Long> {

    List<ReadingActivity> findByUserOrderByStartDateDesc(User user);
    
    List<ReadingActivity> findByUserAndIsCompletedOrderByStartDateDesc(User user, Boolean isCompleted);
    
    List<ReadingActivity> findByUserAndStartDate(User user, LocalDate startDate);
    
    @Query("SELECT COUNT(r) FROM ReadingActivity r WHERE r.user = :user AND r.isCompleted = true")
    Long countCompletedByUser(User user);
}
