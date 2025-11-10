package com.projeto.tcc.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.projeto.tcc.dto.CognitiveActivityStatsDTO;
import com.projeto.tcc.dto.CrosswordActivityDTO;
import com.projeto.tcc.dto.MovieActivityDTO;
import com.projeto.tcc.dto.ReadingActivityDTO;
import com.projeto.tcc.services.CognitiveActivityService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/cognitive-activities")
@CrossOrigin(origins = "*")
public class CognitiveActivityController {

    @Autowired
    private CognitiveActivityService service;

    // ==================== STATISTICS ====================

    @GetMapping("/stats")
    public ResponseEntity<CognitiveActivityStatsDTO> getStatistics() {
        CognitiveActivityStatsDTO stats = service.getStatistics();
        return ResponseEntity.ok(stats);
    }

    // ==================== READING ACTIVITIES ====================

    @GetMapping("/reading")
    public ResponseEntity<List<ReadingActivityDTO>> findAllReadingActivities() {
        List<ReadingActivityDTO> list = service.findAllReadingActivities();
        return ResponseEntity.ok(list);
    }

    @PostMapping("/reading")
    public ResponseEntity<ReadingActivityDTO> saveReadingActivity(@RequestBody @Valid ReadingActivityDTO dto) {
        ReadingActivityDTO saved = service.saveReadingActivity(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/reading/{id}")
    public ResponseEntity<ReadingActivityDTO> updateReadingActivity(
            @PathVariable Long id, 
            @RequestBody @Valid ReadingActivityDTO dto) {
        ReadingActivityDTO updated = service.updateReadingActivity(id, dto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/reading/{id}")
    public ResponseEntity<Void> deleteReadingActivity(@PathVariable Long id) {
        service.deleteReadingActivity(id);
        return ResponseEntity.noContent().build();
    }

    // ==================== CROSSWORD ACTIVITIES ====================

    @GetMapping("/crosswords")
    public ResponseEntity<List<CrosswordActivityDTO>> findAllCrosswordActivities() {
        List<CrosswordActivityDTO> list = service.findAllCrosswordActivities();
        return ResponseEntity.ok(list);
    }

    @PostMapping("/crosswords")
    public ResponseEntity<CrosswordActivityDTO> saveCrosswordActivity(@RequestBody @Valid CrosswordActivityDTO dto) {
        CrosswordActivityDTO saved = service.saveCrosswordActivity(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/crosswords/{id}")
    public ResponseEntity<CrosswordActivityDTO> updateCrosswordActivity(
            @PathVariable Long id, 
            @RequestBody @Valid CrosswordActivityDTO dto) {
        CrosswordActivityDTO updated = service.updateCrosswordActivity(id, dto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/crosswords/{id}")
    public ResponseEntity<Void> deleteCrosswordActivity(@PathVariable Long id) {
        service.deleteCrosswordActivity(id);
        return ResponseEntity.noContent().build();
    }

    // ==================== MOVIE ACTIVITIES ====================

    @GetMapping("/movies")
    public ResponseEntity<List<MovieActivityDTO>> findAllMovieActivities() {
        List<MovieActivityDTO> list = service.findAllMovieActivities();
        return ResponseEntity.ok(list);
    }

    @PostMapping("/movies")
    public ResponseEntity<MovieActivityDTO> saveMovieActivity(@RequestBody @Valid MovieActivityDTO dto) {
        MovieActivityDTO saved = service.saveMovieActivity(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/movies/{id}")
    public ResponseEntity<MovieActivityDTO> updateMovieActivity(
            @PathVariable Long id, 
            @RequestBody @Valid MovieActivityDTO dto) {
        MovieActivityDTO updated = service.updateMovieActivity(id, dto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/movies/{id}")
    public ResponseEntity<Void> deleteMovieActivity(@PathVariable Long id) {
        service.deleteMovieActivity(id);
        return ResponseEntity.noContent().build();
    }
}
