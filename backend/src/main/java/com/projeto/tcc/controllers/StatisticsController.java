package com.projeto.tcc.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.projeto.tcc.dto.UserStatisticsDTO;
import com.projeto.tcc.services.StatisticsService;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class StatisticsController {

    @Autowired
    private StatisticsService statisticsService;

    @GetMapping("/users/{userId}/statistics/summary")
    public ResponseEntity<UserStatisticsDTO> getUserStatisticsSummary(@PathVariable Long userId) {
        UserStatisticsDTO statistics = statisticsService.getUserStatistics(userId);
        return ResponseEntity.ok(statistics);
    }

    @GetMapping("/users/{userId}/statistics/trends")
    public ResponseEntity<UserStatisticsDTO> getUserStatisticsTrends(@PathVariable Long userId) {
        UserStatisticsDTO statistics = statisticsService.getUserStatistics(userId);
        return ResponseEntity.ok(statistics);
    }

    @GetMapping("/users/{userId}/statistics/comparison")
    public ResponseEntity<UserStatisticsDTO> getUserStatisticsComparison(@PathVariable Long userId) {
        UserStatisticsDTO statistics = statisticsService.getUserStatistics(userId);
        return ResponseEntity.ok(statistics);
    }

    @GetMapping("/stats/user-stats")
    public ResponseEntity<UserStatisticsDTO> getUserStats() {
        UserStatisticsDTO statistics = statisticsService.getUserStatistics(1L);
        return ResponseEntity.ok(statistics);
    }

    @GetMapping("/stats/weekly-progress")
    public ResponseEntity<UserStatisticsDTO> getWeeklyProgress() {
        UserStatisticsDTO statistics = statisticsService.getUserStatistics(1L);
        return ResponseEntity.ok(statistics);
    }
}
