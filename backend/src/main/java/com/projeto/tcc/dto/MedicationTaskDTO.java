package com.projeto.tcc.dto;

import java.time.LocalDateTime;

public record MedicationTaskDTO(Long taskId, Long medicineId, String name, String dose, LocalDateTime scheduledTime, boolean taken) {}