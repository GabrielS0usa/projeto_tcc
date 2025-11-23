package com.projeto.tcc.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class GeminiReportResponseManual {
    private String overallAssessment;
    private Map<String, String> healthMetricsAnalysis;
    private String medicationAdherence;
    private String activityEvaluation;
    private String nutritionAnalysis;
    private String cognitiveInsights;
    private List<String> recommendations;
    private String motivationalMessage;
    private LocalDateTime generatedAt;

    public GeminiReportResponseManual() {}

    public GeminiReportResponseManual(String overallAssessment, Map<String, String> healthMetricsAnalysis,
                                    String medicationAdherence, String activityEvaluation,
                                    String nutritionAnalysis, String cognitiveInsights,
                                    List<String> recommendations, String motivationalMessage,
                                    LocalDateTime generatedAt) {
        this.overallAssessment = overallAssessment;
        this.healthMetricsAnalysis = healthMetricsAnalysis;
        this.medicationAdherence = medicationAdherence;
        this.activityEvaluation = activityEvaluation;
        this.nutritionAnalysis = nutritionAnalysis;
        this.cognitiveInsights = cognitiveInsights;
        this.recommendations = recommendations;
        this.motivationalMessage = motivationalMessage;
        this.generatedAt = generatedAt;
    }

    public static GeminiReportResponseBuilder builder() {
        return new GeminiReportResponseBuilder();
    }

    public static class GeminiReportResponseBuilder {
        private String overallAssessment;
        private Map<String, String> healthMetricsAnalysis;
        private String medicationAdherence;
        private String activityEvaluation;
        private String nutritionAnalysis;
        private String cognitiveInsights;
        private List<String> recommendations;
        private String motivationalMessage;
        private LocalDateTime generatedAt;

        public GeminiReportResponseBuilder overallAssessment(String overallAssessment) {
            this.overallAssessment = overallAssessment;
            return this;
        }

        public GeminiReportResponseBuilder healthMetricsAnalysis(Map<String, String> healthMetricsAnalysis) {
            this.healthMetricsAnalysis = healthMetricsAnalysis;
            return this;
        }

        public GeminiReportResponseBuilder medicationAdherence(String medicationAdherence) {
            this.medicationAdherence = medicationAdherence;
            return this;
        }

        public GeminiReportResponseBuilder activityEvaluation(String activityEvaluation) {
            this.activityEvaluation = activityEvaluation;
            return this;
        }

        public GeminiReportResponseBuilder nutritionAnalysis(String nutritionAnalysis) {
            this.nutritionAnalysis = nutritionAnalysis;
            return this;
        }

        public GeminiReportResponseBuilder cognitiveInsights(String cognitiveInsights) {
            this.cognitiveInsights = cognitiveInsights;
            return this;
        }

        public GeminiReportResponseBuilder recommendations(List<String> recommendations) {
            this.recommendations = recommendations;
            return this;
        }

        public GeminiReportResponseBuilder motivationalMessage(String motivationalMessage) {
            this.motivationalMessage = motivationalMessage;
            return this;
        }

        public GeminiReportResponseBuilder generatedAt(LocalDateTime generatedAt) {
            this.generatedAt = generatedAt;
            return this;
        }

        public GeminiReportResponseManual build() {
            return new GeminiReportResponseManual(overallAssessment, healthMetricsAnalysis,
                                                medicationAdherence, activityEvaluation,
                                                nutritionAnalysis, cognitiveInsights,
                                                recommendations, motivationalMessage, generatedAt);
        }
    }

    public String getOverallAssessment() { return overallAssessment; }
    public void setOverallAssessment(String overallAssessment) { this.overallAssessment = overallAssessment; }

    public Map<String, String> getHealthMetricsAnalysis() { return healthMetricsAnalysis; }
    public void setHealthMetricsAnalysis(Map<String, String> healthMetricsAnalysis) { this.healthMetricsAnalysis = healthMetricsAnalysis; }

    public String getMedicationAdherence() { return medicationAdherence; }
    public void setMedicationAdherence(String medicationAdherence) { this.medicationAdherence = medicationAdherence; }

    public String getActivityEvaluation() { return activityEvaluation; }
    public void setActivityEvaluation(String activityEvaluation) { this.activityEvaluation = activityEvaluation; }

    public String getNutritionAnalysis() { return nutritionAnalysis; }
    public void setNutritionAnalysis(String nutritionAnalysis) { this.nutritionAnalysis = nutritionAnalysis; }

    public String getCognitiveInsights() { return cognitiveInsights; }
    public void setCognitiveInsights(String cognitiveInsights) { this.cognitiveInsights = cognitiveInsights; }

    public List<String> getRecommendations() { return recommendations; }
    public void setRecommendations(List<String> recommendations) { this.recommendations = recommendations; }

    public String getMotivationalMessage() { return motivationalMessage; }
    public void setMotivationalMessage(String motivationalMessage) { this.motivationalMessage = motivationalMessage; }

    public LocalDateTime getGeneratedAt() { return generatedAt; }
    public void setGeneratedAt(LocalDateTime generatedAt) { this.generatedAt = generatedAt; }
}
