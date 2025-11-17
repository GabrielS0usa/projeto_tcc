package com.projeto.tcc.dto;

import java.util.Map;

public class ActivityChartsDTO {
    private Map<String, Object> weeklyProgress;       // Existing main screen logic
    private Map<String, Object> categoryBreakdown;    // Enhanced from Activity
    private Map<String, Object> performanceMetrics;   // New comprehensive metrics
    private Map<String, Object> goalTracking;         // Enhanced tracking

    public ActivityChartsDTO() {}

    public ActivityChartsDTO(Map<String, Object> weeklyProgress, Map<String, Object> categoryBreakdown,
                             Map<String, Object> performanceMetrics, Map<String, Object> goalTracking) {
        this.weeklyProgress = weeklyProgress;
        this.categoryBreakdown = categoryBreakdown;
        this.performanceMetrics = performanceMetrics;
        this.goalTracking = goalTracking;
    }

    // Getters and Setters
    public Map<String, Object> getWeeklyProgress() { return weeklyProgress; }
    public void setWeeklyProgress(Map<String, Object> weeklyProgress) { this.weeklyProgress = weeklyProgress; }
    public Map<String, Object> getCategoryBreakdown() { return categoryBreakdown; }
    public void setCategoryBreakdown(Map<String, Object> categoryBreakdown) { this.categoryBreakdown = categoryBreakdown; }
    public Map<String, Object> getPerformanceMetrics() { return performanceMetrics; }
    public void setPerformanceMetrics(Map<String, Object> performanceMetrics) { this.performanceMetrics = performanceMetrics; }
    public Map<String, Object> getGoalTracking() { return goalTracking; }
    public void setGoalTracking(Map<String, Object> goalTracking) { this.goalTracking = goalTracking; }
}
