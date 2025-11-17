package com.projeto.tcc.dto;

import java.time.LocalDateTime;

public class UserStatisticsDTO {
    private StatisticsSummaryDTO summary;
    private ActivityChartsDTO charts; // Enhanced from existing Activity chart logic
    private TrendAnalysisDTO trends;
    private LocalDateTime generatedAt;

    public UserStatisticsDTO() {}

    public UserStatisticsDTO(StatisticsSummaryDTO summary, ActivityChartsDTO charts, TrendAnalysisDTO trends, LocalDateTime generatedAt) {
        this.summary = summary;
        this.charts = charts;
        this.trends = trends;
        this.generatedAt = generatedAt;
    }

    // Getters and Setters
    public StatisticsSummaryDTO getSummary() { return summary; }
    public void setSummary(StatisticsSummaryDTO summary) { this.summary = summary; }
    public ActivityChartsDTO getCharts() { return charts; }
    public void setCharts(ActivityChartsDTO charts) { this.charts = charts; }
    public TrendAnalysisDTO getTrends() { return trends; }
    public void setTrends(TrendAnalysisDTO trends) { this.trends = trends; }
    public LocalDateTime getGeneratedAt() { return generatedAt; }
    public void setGeneratedAt(LocalDateTime generatedAt) { this.generatedAt = generatedAt; }
}
