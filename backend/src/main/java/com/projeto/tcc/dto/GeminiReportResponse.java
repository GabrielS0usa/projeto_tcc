package com.projeto.tcc.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class GeminiReportResponse {
    private String overallAssessment;
    private Map<String, String> healthMetricsAnalysis;
    private String medicationAdherence;
    private String activityEvaluation;
    private String nutritionAnalysis;
    private String cognitiveInsights;
    private List<String> recommendations;
    private String motivationalMessage;
    private LocalDateTime generatedAt;
    
    private GeminiReportResponse() {}

    public String getOverallAssessment() { return overallAssessment; }
    public Map<String, String> getHealthMetricsAnalysis() { return healthMetricsAnalysis; }
    public String getMedicationAdherence() { return medicationAdherence; }
    public String getActivityEvaluation() { return activityEvaluation; }
    public String getNutritionAnalysis() { return nutritionAnalysis; }
    public String getCognitiveInsights() { return cognitiveInsights; }
    public List<String> getRecommendations() { return recommendations; }
    public String getMotivationalMessage() { return motivationalMessage; }
    public LocalDateTime getGeneratedAt() { return generatedAt; }

    // Builder manual
    public static class Builder {
        private final GeminiReportResponse instance = new GeminiReportResponse();

        public Builder overallAssessment(String overallAssessment) {
            instance.overallAssessment = overallAssessment;
            return this;
        }

        public Builder healthMetricsAnalysis(Map<String, String> healthMetricsAnalysis) {
            instance.healthMetricsAnalysis = healthMetricsAnalysis;
            return this;
        }

        public Builder medicationAdherence(String medicationAdherence) {
            instance.medicationAdherence = medicationAdherence;
            return this;
        }

        public Builder activityEvaluation(String activityEvaluation) {
            instance.activityEvaluation = activityEvaluation;
            return this;
        }

        public Builder nutritionAnalysis(String nutritionAnalysis) {
            instance.nutritionAnalysis = nutritionAnalysis;
            return this;
        }

        public Builder cognitiveInsights(String cognitiveInsights) {
            instance.cognitiveInsights = cognitiveInsights;
            return this;
        }

        public Builder recommendations(List<String> recommendations) {
            instance.recommendations = recommendations;
            return this;
        }

        public Builder motivationalMessage(String motivationalMessage) {
            instance.motivationalMessage = motivationalMessage;
            return this;
        }

        public Builder generatedAt(LocalDateTime generatedAt) {
            instance.generatedAt = generatedAt;
            return this;
        }

        public GeminiReportResponse build() {
            return instance;
        }
    }

    public static Builder builder() {
        return new Builder();
    }

    public void setHealthMetricsAnalysis(Map<String, String> healthMetrics) {
        this.healthMetricsAnalysis = healthMetrics;
    }

    public void setRecommendations(List<String> recommendations) {
        this.recommendations = recommendations;
    }
}
