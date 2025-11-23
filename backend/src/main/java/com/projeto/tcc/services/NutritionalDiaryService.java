package com.projeto.tcc.services;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.core.context.SecurityContextHolder;

import com.projeto.tcc.dto.NutritionalEntryDTO;
import com.projeto.tcc.dto.NutritionalEntryRequest;
import com.projeto.tcc.entities.NutritionalEntry;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.repositories.NutritionalEntryRepository;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.services.exceptions.ResourceNotFoundException;

@Service
@Transactional
public class NutritionalDiaryService {

	@Autowired
	private NutritionalEntryRepository entryRepository;

	@Autowired
	private UserRepository userRepository;

	public User getAuthenticatedUser() {
		var auth = SecurityContextHolder.getContext().getAuthentication();
		if (auth == null || !auth.isAuthenticated()) {
			throw new RuntimeException("Usuário não autenticado");
		}

		String email = auth.getName();
		return userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
	}

	@Transactional(readOnly = true)
	public List<NutritionalEntryDTO> getEntriesByDate(LocalDate date) {
		User user = getAuthenticatedUser();
		List<NutritionalEntry> entries = entryRepository.findByUserAndDate(user, date);
		return entries.stream().map(this::convertToDTO).collect(Collectors.toList());
	}

	public NutritionalEntryDTO createEntry(NutritionalEntryRequest request) {
		User user = getAuthenticatedUser();

		NutritionalEntry entry = new NutritionalEntry(user, request.getDate(), request.getFoodName(),
				request.getMealType(), request.getCalories(), request.getProtein(), request.getCarbs(),
				request.getFat());

		entry = entryRepository.save(entry);
		return convertToDTO(entry);
	}

	public NutritionalEntryDTO updateEntry(Long entryId, NutritionalEntryRequest request) {
		User user = getAuthenticatedUser();

		NutritionalEntry entry = entryRepository.findById(entryId)
				.orElseThrow(() -> new ResourceNotFoundException("Entry not found"));

		if (!entry.getUser().getId().equals(user.getId())) {
			throw new ResourceNotFoundException("Entry not found for this user");
		}

		entry.setDate(request.getDate());
		entry.setFoodName(request.getFoodName());
		entry.setMealType(request.getMealType());
		entry.setCalories(request.getCalories());
		entry.setProtein(request.getProtein());
		entry.setCarbs(request.getCarbs());
		entry.setFat(request.getFat());
		entry.setUpdatedAt(LocalDateTime.now());

		entry = entryRepository.save(entry);
		return convertToDTO(entry);
	}

	public void deleteEntry(Long entryId) {
		User user = getAuthenticatedUser();

		NutritionalEntry entry = entryRepository.findById(entryId)
				.orElseThrow(() -> new ResourceNotFoundException("Entry not found"));

		if (!entry.getUser().getId().equals(user.getId())) {
			throw new ResourceNotFoundException("Entry not found for this user");
		}

		entryRepository.delete(entry);
	}

	private NutritionalEntryDTO convertToDTO(NutritionalEntry entry) {
		return new NutritionalEntryDTO(entry.getId(), entry.getDate(), entry.getFoodName(), entry.getMealType(),
				entry.getCalories(), entry.getProtein(), entry.getCarbs(), entry.getFat(), entry.getCreatedAt(),
				entry.getUpdatedAt());
	}
}
