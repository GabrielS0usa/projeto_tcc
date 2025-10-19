package com.projeto.tcc.services;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.projeto.tcc.dto.MedicationTaskDTO;
import com.projeto.tcc.dto.MedicineDTO;
import com.projeto.tcc.entities.MedicationTask;
import com.projeto.tcc.entities.Medicine;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.repositories.MedicationTaskRepository;
import com.projeto.tcc.repositories.MedicineRepository;
import com.projeto.tcc.repositories.UserRepository;

import jakarta.transaction.Transactional;

@Service
public class MedicineService {

	@Autowired
	private MedicineRepository repository;

	@Autowired
	private UserRepository userRepository;

	@Autowired
	private MedicationTaskRepository taskRepository;

	@Transactional
	public MedicineDTO create(MedicineDTO dto) {
		String email = SecurityContextHolder.getContext().getAuthentication().getName();
		User user = userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

		Medicine entity = new Medicine();
		copyDtoToEntity(dto, entity);
		entity.setUser(user);

		entity = repository.save(entity);
		return new MedicineDTO(entity);
	}

	@Transactional
	public MedicineDTO update(Long id, MedicineDTO dto) {
		Medicine entity = repository.findById(id).orElseThrow(() -> new RuntimeException("Remédio não encontrado"));
		copyDtoToEntity(dto, entity);
		repository.save(entity);
		return new MedicineDTO(entity);
	}

	@Transactional
	public void delete(Long id) {
		repository.deleteById(id);
	}

	@Transactional
	public List<MedicationTaskDTO> findTodayTasks() {
		User user = getCurrentUser();
		List<Medicine> schedules = repository.findByUserOrderByStartDateAscStartTimeAsc(user);
		
		LocalDate today = LocalDate.now();
		List<MedicationTaskDTO> todayTasks = new ArrayList<>();

		for (Medicine schedule : schedules) {
			LocalDate startDate = schedule.getStartDate();
			LocalDate endDate = startDate.plusDays(schedule.getDurationDays() - 1);

			if (!today.isBefore(startDate) && !today.isAfter(endDate)) {

				LocalDateTime taskTime = today.atTime(schedule.getStartTime());

				while (taskTime.toLocalDate().isEqual(today)) {
					MedicationTask task = findOrCreateTask(schedule, taskTime);

					todayTasks.add(new MedicationTaskDTO(task.getId(), schedule.getName(), schedule.getDose(),
							task.getScheduledTime(), task.isTaken()));

					taskTime = taskTime.plusHours(schedule.getIntervalHours());
				}
			}
		}
		return todayTasks;
	}

	@Transactional
	public void updateTaskStatus(Long taskId, boolean taken) {
		User user = getCurrentUser();
		MedicationTask task = taskRepository.findById(taskId)
				.orElseThrow(() -> new RuntimeException("Tarefa não encontrada"));

		if (!task.getMedicine().getUser().equals(user)) {
			throw new SecurityException("Acesso negado à tarefa.");
		}

		task.setTaken(taken);
		taskRepository.save(task);
	}

	private User getCurrentUser() {
		String email = SecurityContextHolder.getContext().getAuthentication().getName();
		return userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
	}

	private MedicationTask findOrCreateTask(Medicine schedule, LocalDateTime scheduledTime) {
		return taskRepository.findByMedicineIdAndScheduledTime(schedule.getId(), scheduledTime).orElseGet(() -> {
			MedicationTask newTask = new MedicationTask(schedule, scheduledTime);
			return taskRepository.save(newTask);
		});
	}

	@Transactional
	public List<MedicineDTO> findMyMedicines() {
		String email = SecurityContextHolder.getContext().getAuthentication().getName();
		User user = userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
		return repository.findByUserOrderByStartDateAscStartTimeAsc(user).stream().map(MedicineDTO::new)
				.collect(Collectors.toList());
	}

	private void copyDtoToEntity(MedicineDTO dto, Medicine entity) {
		entity.setName(dto.getName());
		entity.setDose(dto.getDose());
		entity.setStartTime(dto.getStartTime());
		entity.setIntervalHours(dto.getIntervalHours());
		entity.setDurationDays(dto.getDurationDays());
		entity.setStartDate(dto.getStartDate());
	}
}