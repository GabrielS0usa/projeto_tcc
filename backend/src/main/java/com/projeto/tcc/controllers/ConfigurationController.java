package com.projeto.tcc.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.projeto.tcc.dto.ConsentUpdateRequest;
import com.projeto.tcc.dto.ConsentRequestDTO;
import com.projeto.tcc.dto.ConsentResponseDTO;
import com.projeto.tcc.dto.UserProfileDTO;
import com.projeto.tcc.dto.UserUpdateRequest;
import com.projeto.tcc.services.UserConsentService;
import com.projeto.tcc.services.UserProfileService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ConfigurationController {

    @Autowired
    private UserProfileService userProfileService;

    @Autowired
    private UserConsentService userConsentService;

    @PostMapping("/auth/logout")
    public ResponseEntity<Void> logout(HttpServletRequest request) {
        // Invalidate token - in production, add token to blacklist
        // For now, just return success
        return ResponseEntity.ok().build();
    }

    @PutMapping("/user/profile")
    public ResponseEntity<UserProfileDTO> updateProfile(@RequestParam Long id, @RequestBody @Valid UserUpdateRequest request) {
        UserProfileDTO updatedProfile = userProfileService.updateUserProfile(id, request);
        return ResponseEntity.ok(updatedProfile);
    }

    @PutMapping("/user/consent")
    public ResponseEntity<ConsentResponseDTO> updateConsent(@RequestBody ConsentUpdateRequest request) {
        // For now, using userId 1 as default. In production, get from JWT token
        ConsentResponseDTO updatedConsent = userConsentService.updateUserConsent(1L, new ConsentRequestDTO(
            request.isMarketingConsent(),
            request.isDataProcessingConsent(),
            request.isTermsAccepted(),
            true, // active
            null  // caregiverEmail
        ));
        return ResponseEntity.ok(updatedConsent);
    }
}
