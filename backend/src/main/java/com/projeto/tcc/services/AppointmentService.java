package com.projeto.tcc.services;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.projeto.tcc.dto.AppointmentDTO;
import com.projeto.tcc.entities.Appointment;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.repositories.AppointmentRepository;
import com.projeto.tcc.repositories.UserRepository;

@Service
public class AppointmentService {

	@Autowired
	private AppointmentRepository repository;

	@Autowired
	private UserRepository userRepository;

	private User getCurrentUser() {
		String email = SecurityContextHolder.getContext().getAuthentication().getName();
		return userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
	}

	@Transactional(readOnly = true)
	public List<AppointmentDTO> findAll() {
	    User user = getCurrentUser();
	    List<Appointment> list = repository.findByUserOrderByDateAsc(user); 
	    return list.stream().map(AppointmentDTO::new).collect(Collectors.toList());
	}

	@Transactional
	public AppointmentDTO save(AppointmentDTO dto) {
		User user = getCurrentUser();
		Appointment entity = new Appointment();
		copyDtoToEntity(dto, entity);
		entity.setUser(user);
		entity = repository.save(entity);
		return new AppointmentDTO(entity);
	}

	@Transactional
	public AppointmentDTO update(Long id, AppointmentDTO dto) {
		User user = getCurrentUser();
		Appointment entity = repository.findById(id)
				.orElseThrow(() -> new RuntimeException("Compromisso não encontrado"));

		if (!entity.getUser().equals(user)) {
			throw new SecurityException("Acesso negado");
		}

		copyDtoToEntity(dto, entity);
		entity = repository.save(entity);
		return new AppointmentDTO(entity);
	}

	@Transactional
	public void delete(Long id) {
		User user = getCurrentUser();
		Appointment entity = repository.findById(id)
				.orElseThrow(() -> new RuntimeException("Compromisso não encontrado"));

		if (!entity.getUser().equals(user)) {
			throw new SecurityException("Acesso negado");
		}

		repository.deleteById(id);
	}

	@Transactional(readOnly = true)
	public List<AppointmentDTO> getAppointmentsForDay(LocalDateTime start, LocalDateTime end) {
		User user = getCurrentUser();
		List<Appointment> list = repository.findByUserAndDateBetween(user, start, end);
		return list.stream().map(AppointmentDTO::new).collect(Collectors.toList());
	}

	private void copyDtoToEntity(AppointmentDTO dto, Appointment entity) {
		entity.setTitle(dto.title());
		entity.setDoctor(dto.doctor());
		entity.setLocation(dto.location());
		entity.setDate(dto.date());
		entity.setType(dto.type());
		entity.setCompleted(dto.isCompleted());
	}
}