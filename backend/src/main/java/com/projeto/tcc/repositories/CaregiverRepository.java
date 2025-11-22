package com.projeto.tcc.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.projeto.tcc.entities.Caregiver;
import com.projeto.tcc.entities.User;

public interface CaregiverRepository extends JpaRepository<Caregiver, Long> {

    Optional<Caregiver> findByEmail(String email);
    
    Optional<Caregiver> findByUser(User user);
    
    Optional<Caregiver> findById(Long id);
}
