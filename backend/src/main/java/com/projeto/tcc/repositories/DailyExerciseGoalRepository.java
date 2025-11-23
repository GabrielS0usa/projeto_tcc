package com.projeto.tcc.repositories;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.projeto.tcc.entities.DailyExerciseGoal;
import com.projeto.tcc.entities.User;

public interface DailyExerciseGoalRepository extends JpaRepository<DailyExerciseGoal, Long> {

	Optional<DailyExerciseGoal> findByUserAndDate(User user, LocalDate date);

	List<DailyExerciseGoal> findByUserAndDateBetweenOrderByDateDesc(User user, LocalDate startDate, LocalDate endDate);

	List<DailyExerciseGoal> findByUserOrderByDateDesc(User user);
}
