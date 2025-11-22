package com.projeto.tcc.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.projeto.tcc.dto.UserProfileDTO;
import com.projeto.tcc.dto.UserUpdateRequest;
import com.projeto.tcc.entities.Caregiver;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.repositories.CaregiverRepository;
import com.projeto.tcc.repositories.UserRepository;

@Service
public class UserProfileService {

	@Autowired
	private UserRepository userRepository;

	@Autowired
	private CaregiverRepository caregiverRepository;

	@Transactional
	public UserProfileDTO updateUserProfile(Long userId, UserUpdateRequest request) {

	    User user = userRepository.findById(userId)
	            .orElseThrow(() -> new RuntimeException("User not found"));

	    user.setName(request.getName());
	    user.setEmail(request.getEmail());

	    Caregiver caregiver = null;

	    if (request.getCaregiverEmail() != null && !request.getCaregiverEmail().isBlank()) {

	        caregiver = caregiverRepository
	                .findByEmail(request.getCaregiverEmail())
	                .orElseGet(() -> new Caregiver());

	        caregiver.setName(request.getCaregiverName());
	        caregiver.setEmail(request.getCaregiverEmail());
	        caregiver.setUser(user);

	        caregiverRepository.save(caregiver);

	        user.setCaregiver(caregiver);
	    }

	    user = userRepository.save(user);

	    return new UserProfileDTO(
	            user.getName(),
	            user.getEmail(),
	            user.getPhone(),
	            user.getBirthDate(),
	            caregiver != null ? caregiver.getName() : null,
	            caregiver != null ? caregiver.getEmail() : null
	    );
	}


	@Transactional(readOnly = true)
	public UserProfileDTO getUserProfile(Long userId) {
		User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));

		User newUser = userRepository.findByEmail(user.getEmail()).get();
		Caregiver caregiver = caregiverRepository.findByUser(newUser).orElse(null);

		String caregiverName = (caregiver != null) ? caregiver.getName() : null;
		String caregiverEmail = (caregiver != null) ? caregiver.getEmail() : null;
		return new UserProfileDTO(user.getName(), user.getEmail(), user.getPhone(), user.getBirthDate(), caregiverName,
				caregiverEmail);
	}
}
