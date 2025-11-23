package com.projeto.tcc.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.projeto.tcc.entities.Consent;
import com.projeto.tcc.entities.User;

public interface ConsentRepository extends JpaRepository<Consent, Long> {

	Optional<Consent> findByUser(User user);

	Optional<Consent> findByUserId(Long userId);

	@Query("SELECT c FROM Consent c LEFT JOIN FETCH c.caregiver WHERE c.user.id = :userId")
	Optional<Consent> findByUserIdWithCaregiver(@Param("userId") Long userId);
}
