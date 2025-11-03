package com.projeto.tcc.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.projeto.tcc.entities.MovieActivity;
import com.projeto.tcc.entities.User;

public interface MovieActivityRepository extends JpaRepository<MovieActivity, Long> {

    List<MovieActivity> findByUserOrderByWatchDateDesc(User user);
    
    List<MovieActivity> findByUserAndIsWatchedOrderByWatchDateDesc(User user, Boolean isWatched);
    
    @Query("SELECT COUNT(m) FROM MovieActivity m WHERE m.user = :user AND m.isWatched = true")
    Long countWatchedByUser(User user);
}
