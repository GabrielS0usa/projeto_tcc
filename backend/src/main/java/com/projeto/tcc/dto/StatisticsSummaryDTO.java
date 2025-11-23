package com.projeto.tcc.dto;

import java.util.Map;

public class StatisticsSummaryDTO {
    private Double totalValue;
    private Long totalActivities;
    private Map<String, Double> averagesByType;
    private Integer averageQualityScore;

    public StatisticsSummaryDTO() {}

    public StatisticsSummaryDTO(Double totalValue, Long totalActivities, Map<String, Double> averagesByType, Integer averageQualityScore) {
        this.totalValue = totalValue;
        this.totalActivities = totalActivities;
        this.averagesByType = averagesByType;
        this.averageQualityScore = averageQualityScore;
    }

    public Double getTotalValue() { return totalValue; }
    public void setTotalValue(Double totalValue) { this.totalValue = totalValue; }
    public Long getTotalActivities() { return totalActivities; }
    public void setTotalActivities(Long totalActivities) { this.totalActivities = totalActivities; }
    public Map<String, Double> getAveragesByType() { return averagesByType; }
    public void setAveragesByType(Map<String, Double> averagesByType) { this.averagesByType = averagesByType; }
    public Integer getAverageQualityScore() { return averageQualityScore; }
    public void setAverageQualityScore(Integer averageQualityScore) { this.averageQualityScore = averageQualityScore; }
}
