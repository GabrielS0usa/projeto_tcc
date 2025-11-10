package com.projeto.tcc.repositories;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.projeto.tcc.entities.DayPeriod;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.entities.Wellness;

public interface WellnessRepository extends JpaRepository<Wellness, Long> {

    Optional<Wellness> findByUserAndEntryDateAndPeriod(User user, LocalDate entryDate, DayPeriod period);
    
    List<Wellness> findByUserAndEntryDate(User user, LocalDate entryDate);
}