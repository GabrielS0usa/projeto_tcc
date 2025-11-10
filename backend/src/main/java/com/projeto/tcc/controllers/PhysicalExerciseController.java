package com.projeto.tcc.controllers;

import java.time.LocalDate;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.projeto.tcc.dto.DailyExerciseGoalDTO;
import com.projeto.tcc.dto.PhysicalActivityDTO;
import com.projeto.tcc.dto.WalkingSessionDTO;
import com.projeto.tcc.dto.WeeklyExerciseSummaryDTO;
import com.projeto.tcc.services.PhysicalExerciseService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/physical-exercises")
@CrossOrigin(origins = "*")
public class PhysicalExerciseController {

    @Autowired
    private PhysicalExerciseService service;

    // ==================== Walking Session Endpoints ====================

    @PostMapping("/walking/start")
    public ResponseEntity<WalkingSessionDTO> startWalkingSession(@RequestBody @Valid WalkingSessionDTO dto) {
        WalkingSessionDTO created = service.startWalkingSession(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/walking/{id}/end")
    public ResponseEntity<WalkingSessionDTO> endWalkingSession(
            @PathVariable Long id,
            @RequestBody @Valid WalkingSessionDTO dto) {
        WalkingSessionDTO updated = service.endWalkingSession(id, dto);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/walking/active")
    public ResponseEntity<WalkingSessionDTO> getActiveWalkingSession() {
        WalkingSessionDTO session = service.getActiveWalkingSession();
        if (session == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(session);
    }

    @GetMapping("/walking")
    public ResponseEntity<List<WalkingSessionDTO>> getAllWalkingSessions() {
        List<WalkingSessionDTO> sessions = service.getAllWalkingSessions();
        return ResponseEntity.ok(sessions);
    }

    @GetMapping("/walking/range")
    public ResponseEntity<List<WalkingSessionDTO>> getWalkingSessionsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<WalkingSessionDTO> sessions = service.getWalkingSessionsByDateRange(startDate, endDate);
        return ResponseEntity.ok(sessions);
    }

    @DeleteMapping("/walking/{id}")
    public ResponseEntity<Void> deleteWalkingSession(@PathVariable Long id) {
        service.deleteWalkingSession(id);
        return ResponseEntity.noContent().build();
    }

    // ==================== Physical Activity Endpoints ====================

    @PostMapping("/activities")
    public ResponseEntity<PhysicalActivityDTO> createPhysicalActivity(@RequestBody @Valid PhysicalActivityDTO dto) {
        PhysicalActivityDTO created = service.createPhysicalActivity(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/activities/{id}")
    public ResponseEntity<PhysicalActivityDTO> updatePhysicalActivity(
            @PathVariable Long id,
            @RequestBody @Valid PhysicalActivityDTO dto) {
        PhysicalActivityDTO updated = service.updatePhysicalActivity(id, dto);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/activities")
    public ResponseEntity<List<PhysicalActivityDTO>> getAllPhysicalActivities() {
        List<PhysicalActivityDTO> activities = service.getAllPhysicalActivities();
        return ResponseEntity.ok(activities);
    }

    @GetMapping("/activities/range")
    public ResponseEntity<List<PhysicalActivityDTO>> getPhysicalActivitiesByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<PhysicalActivityDTO> activities = service.getPhysicalActivitiesByDateRange(startDate, endDate);
        return ResponseEntity.ok(activities);
    }

    @DeleteMapping("/activities/{id}")
    public ResponseEntity<Void> deletePhysicalActivity(@PathVariable Long id) {
        service.deletePhysicalActivity(id);
        return ResponseEntity.noContent().build();
    }

    // ==================== Daily Exercise Goal Endpoints ====================

    @GetMapping("/goals/today")
    public ResponseEntity<DailyExerciseGoalDTO> getTodayGoal() {
        DailyExerciseGoalDTO goal = service.getTodayGoal();
        return ResponseEntity.ok(goal);
    }

    @PutMapping("/goals")
    public ResponseEntity<DailyExerciseGoalDTO> updateDailyGoal(@RequestBody @Valid DailyExerciseGoalDTO dto) {
        DailyExerciseGoalDTO updated = service.updateDailyGoal(dto);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/summary/weekly")
    public ResponseEntity<WeeklyExerciseSummaryDTO> getWeeklySummary() {
        WeeklyExerciseSummaryDTO summary = service.getWeeklySummary();
        return ResponseEntity.ok(summary);
    }
}
