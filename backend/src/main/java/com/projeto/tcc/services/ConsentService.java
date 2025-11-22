package com.projeto.tcc.services;

import com.projeto.tcc.dto.ConsentRequestDTO;
import com.projeto.tcc.dto.ConsentResponseDTO;
import com.projeto.tcc.entities.Caregiver;
import com.projeto.tcc.entities.Consent;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.repositories.CaregiverRepository;
import com.projeto.tcc.repositories.ConsentRepository;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.services.exceptions.ResourceNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ConsentService {

    @Autowired
    private ConsentRepository consentRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CaregiverRepository caregiverRepository;

    @Transactional(readOnly = true)
    public ConsentResponseDTO getConsentStatus() {
        User user = getCurrentUser();
        Consent consent = consentRepository.findByUser(user)
                .orElse(null);

        if (consent == null) {

            return new ConsentResponseDTO();
        } else {
            return new ConsentResponseDTO(consent);
        }
    }

    @Transactional
    public ConsentResponseDTO updateConsent(ConsentRequestDTO dto) {
        User user = getCurrentUser();
        Caregiver caregiver = null;

        if (Boolean.TRUE.equals(dto.active())) {
            if (dto.caregiverEmail() == null || dto.caregiverEmail().isBlank()) {
                throw new IllegalArgumentException("Email do cuidador é obrigatório para ativar o consentimento.");
            }
 
            caregiver = caregiverRepository.findByEmail(dto.caregiverEmail())
                    .orElseThrow(() -> new ResourceNotFoundException("Cuidador não encontrado com o email fornecido."));
        }

        Consent consent = consentRepository.findByUser(user)
                .orElse(new Consent());

        consent.setUser(user);
        consent.setActive(Boolean.TRUE.equals(dto.active()));
        consent.setCaregiver(caregiver); 

        consent = consentRepository.save(consent);

        return new ConsentResponseDTO(consent);
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Usuário não encontrado: " + email));
    }
}
