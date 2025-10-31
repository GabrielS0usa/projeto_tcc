package com.projeto.tcc.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.projeto.tcc.dto.WellnessEntryDTO;
import com.projeto.tcc.services.WellnessService;

import jakarta.validation.Valid;

@RestController
@RequestMapping(value = "/wellness-diary")
public class WellnessController {

    @Autowired
    private WellnessService service;

    @PostMapping
    public ResponseEntity<Void> save(@RequestBody @Valid WellnessEntryDTO dto) {
        service.save(dto);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }
    
    @GetMapping("/today")
    public ResponseEntity<List<WellnessEntryDTO>> getTodayEntries() {
        List<WellnessEntryDTO> entries = service.findTodayEntries();
        return ResponseEntity.ok(entries);
    }
}