package com.projeto.tcc.repositories;

import com.projeto.tcc.entities.Consent;
import com.projeto.tcc.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface ConsentRepository extends JpaRepository<Consent, Long> {

    Optional<Consent> findByUser(User user);
}
