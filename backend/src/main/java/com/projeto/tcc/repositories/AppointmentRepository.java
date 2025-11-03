package com.projeto.tcc.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.projeto.tcc.entities.Appointment;
import com.projeto.tcc.entities.User;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    List<Appointment> findByUserOrderByDateAsc(User user);

    List<Appointment> findByUserAndDateBetween(User user, LocalDateTime start, LocalDateTime end);

	List<Appointment> findByUser(User user);
}