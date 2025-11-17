package com.projeto.tcc.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.projeto.tcc.dto.ConsentRequestDTO;
import com.projeto.tcc.dto.ConsentResponseDTO;
import com.projeto.tcc.services.UserConsentService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/users/{userId}/consent")
@CrossOrigin(origins = "*")
public class UserConsentController {

    @Autowired
    private UserConsentService userConsentService;

    @GetMapping
    public ResponseEntity<ConsentResponseDTO> getUserConsent(@PathVariable Long userId) {
        ConsentResponseDTO consent = userConsentService.getUserConsent(userId);
        return ResponseEntity.ok(consent);
    }

    @PutMapping
    public ResponseEntity<ConsentResponseDTO> updateUserConsent(@PathVariable Long userId, @RequestBody ConsentRequestDTO request) {
        ConsentResponseDTO updatedConsent = userConsentService.updateUserConsent(userId, request);
        return ResponseEntity.ok(updatedConsent);
    }
}
