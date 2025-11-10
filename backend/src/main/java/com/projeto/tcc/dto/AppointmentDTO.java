package com.projeto.tcc.dto;

import com.projeto.tcc.entities.Appointment;
import com.projeto.tcc.entities.AppointmentType;
import java.time.LocalDateTime;

public record AppointmentDTO(Long id, String title, AppointmentType type, LocalDateTime date, String doctor,
		String location, boolean isCompleted) {

	public AppointmentDTO(Appointment entity) {
		this(entity.getId(), entity.getTitle(), entity.getType(), entity.getDate(), entity.getDoctor(),
				entity.getLocation(), entity.isCompleted());
	}
	
	
}

