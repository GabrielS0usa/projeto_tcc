package com.projeto.tcc.controllers;

import java.time.LocalDate;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.projeto.tcc.dto.NutritionalEntryDTO;
import com.projeto.tcc.dto.NutritionalEntryRequest;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.services.NutritionalDiaryService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/diary")
@CrossOrigin(origins = "*")
public class DiaryController {

    @Autowired
    private NutritionalDiaryService diaryService;

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/entries")
    public ResponseEntity<List<NutritionalEntryDTO>> getEntriesByDate(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(diaryService.getEntriesByDate(date));
    }

    @PostMapping("/entries")
    public ResponseEntity<NutritionalEntryDTO> createEntry(
            @RequestBody @Valid NutritionalEntryRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(diaryService.createEntry(request));
    }

    @PutMapping("/entries/{id}")
    public ResponseEntity<NutritionalEntryDTO> updateEntry(
            @PathVariable Long id,
            @RequestBody @Valid NutritionalEntryRequest request) {
        return ResponseEntity.ok(diaryService.updateEntry(id, request));
    }

    @DeleteMapping("/entries/{id}")
    public ResponseEntity<Void> deleteEntry(@PathVariable Long id) {
        diaryService.deleteEntry(id);
        return ResponseEntity.noContent().build();
    }

}