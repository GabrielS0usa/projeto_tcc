package com.projeto.tcc.services;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.projeto.tcc.dto.ConsentRequestDTO;
import com.projeto.tcc.dto.ConsentResponseDTO;
import com.projeto.tcc.entities.Caregiver;
import com.projeto.tcc.entities.Consent;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.repositories.CaregiverRepository;
import com.projeto.tcc.repositories.ConsentRepository;
import com.projeto.tcc.repositories.UserRepository;

@Service
public class UserConsentService {

    @Autowired
    private ConsentRepository consentRepository;

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    CaregiverRepository caregiverRepository;

    @Transactional
    public ConsentResponseDTO updateUserConsent(Long userId, ConsentRequestDTO request) {

        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));

        Consent consent = user.getConsent();
        if (consent == null) {
            consent = new Consent();
            consent.setUser(user);
            user.setConsent(consent);
        }

        consent.setDataSharing(request.dataSharing());
        consent.setAnalytics(request.analytics());
        consent.setNotifications(request.notifications());
        consent.setLastUpdated(LocalDateTime.now());
        consent.setActive(request.active());

        if (request.caregiverEmail() != null && !request.caregiverEmail().isBlank()) {
			Caregiver caregiver = caregiverRepository.findByEmail(request.caregiverEmail())
                .orElseThrow(() -> new RuntimeException("Caregiver not found"));
            consent.setCaregiver(caregiver);
        } else {
            consent.setCaregiver(null);
        }

        consent = consentRepository.save(consent);

        return new ConsentResponseDTO(consent);
    }


    @Transactional(readOnly = true)
    public ConsentResponseDTO getUserConsent(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));

        Consent consent = user.getConsent();
        if (consent == null) {
            return new ConsentResponseDTO();
        }

        return new ConsentResponseDTO(consent);
    }
}
