package com.projeto.tcc.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.projeto.tcc.entities.medicine;

@Repository
public interface MedicineRepository extends JpaRepository<medicine, Long> {
}
