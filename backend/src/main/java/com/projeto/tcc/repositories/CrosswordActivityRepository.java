package com.projeto.tcc.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.projeto.tcc.entities.CrosswordActivity;
import com.projeto.tcc.entities.User;

public interface CrosswordActivityRepository extends JpaRepository<CrosswordActivity, Long> {

    List<CrosswordActivity> findByUserOrderByDateDesc(User user);
    
    List<CrosswordActivity> findByUserAndIsCompletedOrderByDateDesc(User user, Boolean isCompleted);
    
    @Query("SELECT COUNT(c) FROM CrosswordActivity c WHERE c.user = :user AND c.isCompleted = true")
    Long countCompletedByUser(User user);
}
