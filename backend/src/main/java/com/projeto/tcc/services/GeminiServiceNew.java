package com.projeto.tcc.services;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.projeto.tcc.dto.DailyDataBundle;
import com.projeto.tcc.dto.GeminiReportResponse;
import com.projeto.tcc.entities.*;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.services.exceptions.ResourceNotFoundException;

@Service
public class GeminiServiceNew {

    private static final Logger logger = LoggerFactory.getLogger(GeminiServiceNew.class);

    @Value("${gemini.api.url}")
    private String geminiApiUrl;

    @Value("${gemini.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate;
    private final DailyDataAggregator dailyDataAggregator;
    private final ObjectMapper objectMapper;
    
    @Autowired
    private UserRepository userRepository;

    @Autowired
    public GeminiServiceNew(RestTemplate restTemplate, DailyDataAggregator dailyDataAggregator, ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.dailyDataAggregator = dailyDataAggregator;
        this.objectMapper = objectMapper;
    }

    public GeminiReportResponse generateDailyReport(String userId, LocalDate date) {
        logger.info("Generating daily wellness report for user: {} on date: {}", userId, date);
        
        User user = getCurrentUser();

        if (apiKey == null || apiKey.isEmpty() || apiKey.equals("SUA_KEY_AQUI")) {
            logger.error("Gemini API Key is not configured");
            throw new RuntimeException("Gemini API Key is not configured");
        }

        DailyDataBundle dailyData = dailyDataAggregator.aggregateDailyData(user.getId(), date);
        String prompt = createComprehensivePrompt(dailyData);
        String rawResponse = sendToGeminiAPI(prompt);

        return parseGeminiResponse(rawResponse);
    }

    private String createComprehensivePrompt(DailyDataBundle data) {
        StringBuilder prompt = new StringBuilder();

        prompt.append("Act as a personal health and wellness assistant. ")
              .append("Analyze the following comprehensive daily data and provide a structured wellness report:\n\n");

        // User context
        prompt.append("USER PROFILE:\n")
        .append("- Name: ").append(data.getUser().getName()).append("\n")
        .append("- Age: ").append(calculateAge(data.getUser().getBirthDate())).append("\n\n");

        // Wellness metrics
        if (data.getWellness() != null) {
            prompt.append("WELLNESS & MENTAL HEALTH:\n")
                  .append("- Mood: ").append(data.getWellness().getMood()).append("\n")
                  .append("- Period: ").append(data.getWellness().getPeriod()).append("\n")
                  .append("- Notes: ").append(data.getWellness().getNote() != null ? data.getWellness().getNote() : "None").append("\n\n");
        } else {
            prompt.append("WELLNESS & MENTAL HEALTH:\n")
                  .append("- No wellness data recorded for this date\n\n");
        }

        // Nutrition data
        prompt.append("NUTRITIONAL INTAKE:\n");
        if (data.getNutritionalEntries() != null && !data.getNutritionalEntries().isEmpty()) {
            data.getNutritionalEntries().forEach(entry -> {
                prompt.append("- ").append(entry.getFoodName())
                      .append(" | Calories: ").append(entry.getCalories())
                      .append(" | Protein: ").append(entry.getProtein()).append("g")
                      .append(" | Carbs: ").append(entry.getCarbs()).append("g")
                      .append(" | Fat: ").append(entry.getFat()).append("g\n");
            });
        } else {
            prompt.append("- No nutritional entries recorded for this date\n");
        }
        prompt.append("\n");

        // Physical activities
        prompt.append("PHYSICAL ACTIVITIES:\n");
        if (data.getPhysicalActivities() != null && !data.getPhysicalActivities().isEmpty()) {
            data.getPhysicalActivities().forEach(activity -> {
                prompt.append("- ").append(activity.getActivityType())
                      .append(" | Duration: ").append(activity.getDurationMinutes()).append("min")
                      .append(" | Calories Burned: ").append(activity.getCaloriesBurned() != null ? activity.getCaloriesBurned() : 0).append("\n");
            });
        } else {
            prompt.append("- No physical activities recorded for this date\n");
        }
        prompt.append("\n");

        // Walking sessions
        prompt.append("WALKING SESSIONS:\n");
        if (data.getWalkingSessions() != null && !data.getWalkingSessions().isEmpty()) {
            data.getWalkingSessions().forEach(walk -> {
                prompt.append("- Steps: ").append(walk.getSteps() != null ? walk.getSteps() : 0)
                      .append(" | Distance: ").append(walk.getDistanceKm() != null ? walk.getDistanceKm() : 0).append("km")
                      .append(" | Duration: ").append(walk.getDurationMinutes() != null ? walk.getDurationMinutes() : 0).append("min\n");
            });
        } else {
            prompt.append("- No walking sessions recorded for this date\n");
        }
        prompt.append("\n");

        // Exercise goals
        if (data.getExerciseGoals() != null) {
            prompt.append("EXERCISE GOALS:\n")
                  .append("- Target Steps: ").append(data.getExerciseGoals().getTargetSteps() != null ? data.getExerciseGoals().getTargetSteps() : 0)
                  .append(" | Current Steps: ").append(data.getExerciseGoals().getCurrentSteps() != null ? data.getExerciseGoals().getCurrentSteps() : 0).append("\n")
                  .append("- Target Minutes: ").append(data.getExerciseGoals().getTargetMinutes() != null ? data.getExerciseGoals().getTargetMinutes() : 0)
                  .append(" | Current Minutes: ").append(data.getExerciseGoals().getCurrentMinutes() != null ? data.getExerciseGoals().getCurrentMinutes() : 0).append("\n")
                  .append("- Target Calories: ").append(data.getExerciseGoals().getTargetCalories() != null ? data.getExerciseGoals().getTargetCalories() : 0)
                  .append(" | Current Calories: ").append(data.getExerciseGoals().getCurrentCalories() != null ? data.getExerciseGoals().getCurrentCalories() : 0).append("\n\n");
        } else {
            prompt.append("EXERCISE GOALS:\n")
                  .append("- No exercise goals set for this date\n\n");
        }

        // Medication adherence
        prompt.append("MEDICATION MANAGEMENT:\n");
        if (data.getMedicines() != null && !data.getMedicines().isEmpty()) {
            data.getMedicines().forEach(medicine -> {
                prompt.append("- ").append(medicine.getName())
                      .append(" | Dose: ").append(medicine.getDose()).append("\n");
            });
        } else {
            prompt.append("- No medicines prescribed\n");
        }

        if (data.getMedicationTasks() != null && !data.getMedicationTasks().isEmpty()) {
            prompt.append("Medication Tasks:\n");
            data.getMedicationTasks().forEach(task -> {
                prompt.append("- ").append(task.getMedicine().getName())
                      .append(" | Scheduled: ").append(task.getScheduledTime())
                      .append(" | Taken: ").append(task.isTaken() ? "YES" : "NO").append("\n");
            });
        }
        prompt.append("\n");

        // Appointments
        prompt.append("MEDICAL APPOINTMENTS:\n");
        if (data.getAppointments() != null && !data.getAppointments().isEmpty()) {
            data.getAppointments().forEach(appointment -> {
                prompt.append("- ").append(appointment.getTitle())
                      .append(" | Type: ").append(appointment.getType())
                      .append(" | Time: ").append(appointment.getDate())
                      .append(" | Location: ").append(appointment.getLocation())
                      .append(" | Completed: ").append(appointment.isCompleted() ? "YES" : "NO").append("\n");
            });
        } else {
            prompt.append("- No appointments scheduled for this date\n");
        }
        prompt.append("\n");

        // Cognitive activities
        prompt.append("COGNITIVE & LEISURE ACTIVITIES:\n");

        // Reading activities
        if (data.getReadingActivities() != null && !data.getReadingActivities().isEmpty()) {
            prompt.append("Reading Activities:\n");
            data.getReadingActivities().forEach(reading -> {
                prompt.append("- Book: ").append(reading.getBookTitle())
                      .append(" | Progress: ").append(reading.getCurrentPage()).append("/").append(reading.getTotalPages())
                      .append(" | Completed: ").append(reading.getIsCompleted() ? "YES" : "NO").append("\n");
            });
        } else {
            prompt.append("- No reading activities for this date\n");
        }

        // Crossword activities
        if (data.getCrosswordActivities() != null && !data.getCrosswordActivities().isEmpty()) {
            prompt.append("Crossword Activities:\n");
            data.getCrosswordActivities().forEach(crossword -> {
                prompt.append("- Puzzle: ").append(crossword.getPuzzleName())
                      .append(" | Difficulty: ").append(crossword.getDifficulty())
                      .append(" | Time Spent: ").append(crossword.getTimeSpentMinutes()).append("min")
                      .append(" | Completed: ").append(crossword.getIsCompleted() ? "YES" : "NO").append("\n");
            });
        } else {
            prompt.append("- No crossword activities for this date\n");
        }

        // Movie activities
        if (data.getMovieActivities() != null && !data.getMovieActivities().isEmpty()) {
            prompt.append("Movie Activities:\n");
            data.getMovieActivities().forEach(movie -> {
                prompt.append("- Movie: ").append(movie.getMovieTitle())
                      .append(" | Genre: ").append(movie.getGenre() != null ? movie.getGenre() : "Not specified")
                      .append(" | Rating: ").append(movie.getRating()).append("/5")
                      .append(" | Watched: ").append(movie.getIsWatched() ? "YES" : "NO").append("\n");
            });
        } else {
            prompt.append("- No movie activities for this date\n");
        }
        prompt.append("\n");

        prompt.append("ANALYSIS REQUEST:\n")
              .append("Please provide a comprehensive wellness report including:\n")
              .append("1. Overall daily assessment and achievements\n")
              .append("2. Health and wellness patterns observed\n")
              .append("3. Medication adherence analysis\n")
              .append("4. Physical activity evaluation\n")
              .append("5. Nutritional balance assessment\n")
              .append("6. Mental and cognitive engagement review\n")
              .append("7. Specific recommendations for improvement\n")
              .append("8. Motivation and encouragement\n\n")
              .append("Format the response in structured JSON with these sections: ")
              .append("overall_assessment, health_metrics_analysis, medication_adherence, ")
              .append("activity_evaluation, nutrition_analysis, cognitive_insights, ")
              .append("recommendations, motivational_message")
              .append("\n\nIMPORTANT: Keep the JSON keys in English, but ensure all values and text content are strictly in Brazilian Portuguese.");

        return prompt.toString();
    }

    private String sendToGeminiAPI(String prompt) {
        try {
            String url = geminiApiUrl + "?key=" + apiKey;

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            Map<String, Object> requestBody = new HashMap<>();
            Map<String, String> part = new HashMap<>();
            part.put("text", prompt);

            Map<String, Object> content = new HashMap<>();
            content.put("parts", List.of(part));

            requestBody.put("contents", List.of(content));

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

            ResponseEntity<GeminiApiResponse> response = restTemplate.postForEntity(url, entity, GeminiApiResponse.class);

            if (response.getBody() != null && response.getBody().getCandidates() != null && !response.getBody().getCandidates().isEmpty()) {
                return response.getBody().getCandidates().get(0).getContent().getParts().get(0).getText();
            } else {
                logger.error("Invalid response from Gemini API");
                throw new RuntimeException("Invalid response from Gemini API");
            }

        } catch (RestClientException e) {
            logger.error("Error calling Gemini API: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to communicate with Gemini API", e);
        } catch (Exception e) {
            logger.error("Unexpected error in GeminiService: {}", e.getMessage(), e);
            throw new RuntimeException("Internal error processing Gemini response", e);
        }
    }

    private GeminiReportResponse parseGeminiResponse(String rawResponse) {
        try {
            // Remove markdown code blocks (```json e ```)
            String cleanedResponse = rawResponse
                .replaceAll("```json\\s*", "")
                .replaceAll("```\\s*", "")
                .trim();
            
            logger.info("Cleaned response: {}", cleanedResponse);
            
            // Try to parse as JSON
            JsonNode jsonNode = objectMapper.readTree(cleanedResponse);

            GeminiReportResponse response = GeminiReportResponse.builder()
                .overallAssessment(getJsonField(jsonNode, "overall_assessment"))
                .medicationAdherence(getJsonField(jsonNode, "medication_adherence"))
                .activityEvaluation(getJsonField(jsonNode, "activity_evaluation"))
                .nutritionAnalysis(getJsonField(jsonNode, "nutrition_analysis"))
                .cognitiveInsights(getJsonField(jsonNode, "cognitive_insights"))
                .motivationalMessage(getJsonField(jsonNode, "motivational_message"))
                .generatedAt(LocalDateTime.now())
                .build();

            // Parse recommendations as list
            if (jsonNode.has("recommendations")) {
                JsonNode recommendationsNode = jsonNode.get("recommendations");
                if (recommendationsNode.isArray()) {
                    List<String> recommendations = objectMapper.convertValue(recommendationsNode, List.class);
                    response.setRecommendations(recommendations);
                }
            }

            // Parse health metrics analysis as map
            if (jsonNode.has("health_metrics_analysis")) {
                JsonNode healthMetricsNode = jsonNode.get("health_metrics_analysis");
                if (healthMetricsNode.isObject()) {
                    Map<String, String> healthMetrics = objectMapper.convertValue(healthMetricsNode, Map.class);
                    response.setHealthMetricsAnalysis(healthMetrics);
                }
            }

            return response;

        } catch (Exception e) {
            logger.warn("Failed to parse Gemini response as JSON, returning raw response: {}", e.getMessage());
            // Fallback: return a basic response with the raw text
            return GeminiReportResponse.builder()
                .overallAssessment(rawResponse)
                .generatedAt(LocalDateTime.now())
                .build();
        }
    }

    private String getJsonField(JsonNode jsonNode, String fieldName) {
        return jsonNode.has(fieldName) ? jsonNode.get(fieldName).asText() : null;
    }

    private int calculateAge(LocalDate birthDate) {
        if (birthDate == null) return 0;
        return LocalDate.now().getYear() - birthDate.getYear();
    }

    // Legacy method for backward compatibility
    public String generateReport(Long userId, LocalDate startDate, LocalDate endDate) {
        // This method is kept for backward compatibility
        // For now, just generate report for the start date
        try {
            GeminiReportResponse response = generateDailyReport(userId.toString(), startDate);
            return formatLegacyResponse(response);
        } catch (Exception e) {
            logger.error("Error generating legacy report: {}", e.getMessage());
            return "Error generating report: " + e.getMessage();
        }
    }

    private String formatLegacyResponse(GeminiReportResponse response) {
        StringBuilder sb = new StringBuilder();
        if (response.getOverallAssessment() != null) {
            sb.append("**Resumo Geral:**\n").append(response.getOverallAssessment()).append("\n\n");
        }
        if (response.getMotivationalMessage() != null) {
            sb.append("**Mensagem Motivacional:**\n").append(response.getMotivationalMessage()).append("\n\n");
        }
        if (response.getRecommendations() != null && !response.getRecommendations().isEmpty()) {
            sb.append("**Recomendações:**\n");
            response.getRecommendations().forEach(rec -> sb.append("- ").append(rec).append("\n"));
        }
        return sb.toString();
    }
    
    public User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
       return userRepository.findByEmail(email)
               .orElseThrow(() -> new RuntimeException("Usuário não encontrado para o token atual"));
   }

    // API Response classes
    static class GeminiApiResponse {
        private List<Candidate> candidates;

        public List<Candidate> getCandidates() { return candidates; }
        public void setCandidates(List<Candidate> candidates) { this.candidates = candidates; }

        static class Candidate {
            private Content content;
            public Content getContent() { return content; }
            public void setContent(Content content) { this.content = content; }
        }

        static class Content {
            private List<Part> parts;
            public List<Part> getParts() { return parts; }
            public void setParts(List<Part> parts) { this.parts = parts; }
        }

        static class Part {
            private String text;
            public String getText() { return text; }
            public void setText(String text) { this.text = text; }
        }
    }
}
