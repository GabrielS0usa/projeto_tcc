package com.projeto.tcc.repositories;

import com.projeto.tcc.entities.MedicationTask;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.Optional;

public interface MedicationTaskRepository extends JpaRepository<MedicationTask, Long> {
    
    Optional<MedicationTask> findByMedicineIdAndScheduledTime(Long medicineId, LocalDateTime scheduledTime);
}