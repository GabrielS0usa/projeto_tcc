package com.projeto.tcc.repositories;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.projeto.tcc.entities.NutritionalEntry;
import com.projeto.tcc.entities.User;

@Repository
public interface NutritionalEntryRepository extends JpaRepository<NutritionalEntry, Long> {

	List<NutritionalEntry> findByUserAndDate(User user, LocalDate date);

	List<NutritionalEntry> findByUserAndDateBetween(User user, LocalDate startDate, LocalDate endDate);

	@Query("SELECT n FROM NutritionalEntry n WHERE n.user = :user AND CAST(n.date AS date) = :date")
	List<NutritionalEntry> findByUserAndDateEquals(@Param("user") User user, @Param("date") LocalDate date);
}
