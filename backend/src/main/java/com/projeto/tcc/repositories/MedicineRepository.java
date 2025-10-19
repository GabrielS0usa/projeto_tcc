package com.projeto.tcc.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.projeto.tcc.entities.Medicine;
import com.projeto.tcc.entities.User;

public interface MedicineRepository extends JpaRepository<Medicine, Long> {
    List<Medicine> findByUserOrderByStartDateAscStartTimeAsc(User user);
}
