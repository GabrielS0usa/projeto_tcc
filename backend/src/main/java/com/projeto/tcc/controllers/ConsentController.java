package com.projeto.tcc.controllers;

import com.projeto.tcc.dto.ConsentRequestDTO;
import com.projeto.tcc.dto.ConsentResponseDTO;
import com.projeto.tcc.services.ConsentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/consent") 
public class ConsentController {

    @Autowired
    private ConsentService service;

    @GetMapping
    public ResponseEntity<ConsentResponseDTO> getConsentStatus() {
        ConsentResponseDTO dto = service.getConsentStatus();
        return ResponseEntity.ok(dto);
    }

    @PutMapping
    public ResponseEntity<ConsentResponseDTO> updateConsent(@Valid @RequestBody ConsentRequestDTO dto) {
        ConsentResponseDTO updatedDto = service.updateConsent(dto);
        return ResponseEntity.ok(updatedDto);
    }
}
