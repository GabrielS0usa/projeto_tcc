package com.projeto.tcc.services;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.projeto.tcc.dto.ActivityChartsDTO;
import com.projeto.tcc.dto.ActivityTrendDTO;
import com.projeto.tcc.dto.StatisticsSummaryDTO;
import com.projeto.tcc.dto.TrendAnalysisDTO;
import com.projeto.tcc.dto.UserStatisticsDTO;
import com.projeto.tcc.entities.Activity;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.repositories.ActivityRepository;
import com.projeto.tcc.repositories.UserRepository;

@Service
@Transactional
public class StatisticsService {

    @Autowired
    private ActivityRepository activityRepository;

    @Autowired
    private UserRepository userRepository;

    // Build upon existing Activity aggregation patterns
    public UserStatisticsDTO getUserStatistics(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));

        // Use enhanced Activity entity for calculations
        List<Activity> userActivities = activityRepository.findByUserAndTimestampBetween(
            user, LocalDateTime.now().minusMonths(1), LocalDateTime.now());

        return aggregateStatisticsFromActivities(userActivities);
    }

    private UserStatisticsDTO aggregateStatisticsFromActivities(List<Activity> activities) {
        // Enhance existing chart logic from Activity entity
        StatisticsSummaryDTO summary = calculateSummary(activities);
        ActivityChartsDTO charts = new ActivityChartsDTO(generateWeeklyProgressChart(activities),
                                                          generateCategoryDistribution(activities),
                                                          generatePerformanceTrends(activities),
                                                          generateGoalAchievementChart(activities));
        TrendAnalysisDTO trends = analyzeTrends(activities);

        return new UserStatisticsDTO(summary, charts, trends, LocalDateTime.now());
    }

    // Improve existing chart generation logic from Activity
    private Map<String, Object> generateWeeklyProgressChart(List<Activity> activities) {
        // Extend current Activity chart logic for comprehensive visualization
        Map<String, Object> chart = new HashMap<>();
        // Implementation for weekly progress
        chart.put("type", "line");
        chart.put("data", activities.stream().collect(Collectors.groupingBy(
            a -> a.getTimestamp().toLocalDate(),
            Collectors.summingDouble(Activity::getValue)
        )));
        return chart;
    }

    private Map<String, Object> generateCategoryDistribution(List<Activity> activities) {
        Map<String, Object> chart = new HashMap<>();
        chart.put("type", "pie");
        chart.put("data", activities.stream().collect(Collectors.groupingBy(
            a -> a.getType().name(),
            Collectors.counting()
        )));
        return chart;
    }

    private Map<String, Object> generatePerformanceTrends(List<Activity> activities) {
        Map<String, Object> chart = new HashMap<>();
        chart.put("type", "bar");
        chart.put("data", activities.stream().collect(Collectors.groupingBy(
            a -> a.getType().name(),
            Collectors.averagingDouble(Activity::getValue)
        )));
        return chart;
    }

    private Map<String, Object> generateGoalAchievementChart(List<Activity> activities) {
        Map<String, Object> chart = new HashMap<>();
        chart.put("type", "progress");
        long achieved = activities.stream().filter(Activity::isWithinTargetRange).count();
        chart.put("achieved", achieved);
        chart.put("total", activities.size());
        return chart;
    }

    private StatisticsSummaryDTO calculateSummary(List<Activity> activities) {
        Double totalValue = activities.stream().mapToDouble(Activity::getValue).sum();
        Long totalActivities = (long) activities.size();
        Map<String, Double> averagesByType = activities.stream().collect(Collectors.groupingBy(
            a -> a.getType().name(),
            Collectors.averagingDouble(Activity::getValue)
        ));
        Integer averageQualityScore = (int) activities.stream()
            .filter(a -> a.getQualityScore() != null)
            .mapToInt(Activity::getQualityScore).average().orElse(0.0);

        return new StatisticsSummaryDTO(totalValue, totalActivities, averagesByType, averageQualityScore);
    }

    private TrendAnalysisDTO analyzeTrends(List<Activity> activities) {
        if (activities.isEmpty()) {
            return new TrendAnalysisDTO("daily", List.of(), 0.0, "stable");
        }
        List<ActivityTrendDTO> trends = activityRepository.findDailyTrends(
            activities.get(0).getUser(), LocalDateTime.now().minusMonths(1), LocalDateTime.now());
        // Simple trend analysis
        Double trendSlope = 0.0; // Placeholder
        String trendDirection = "stable"; // Placeholder

        return new TrendAnalysisDTO("daily", trends, trendSlope, trendDirection);
    }
}
