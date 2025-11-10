package com.projeto.tcc.repositories;

import com.projeto.tcc.entities.Caregiver;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface CaregiverRepository extends JpaRepository<Caregiver, Long> {

    Optional<Caregiver> findByEmail(String email);
}
