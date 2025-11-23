package com.projeto.tcc.services;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
	public GeminiServiceNew(RestTemplate restTemplate, DailyDataAggregator dailyDataAggregator,
			ObjectMapper objectMapper) {
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
		String prompt = createStructuredPromptForJson(dailyData, date);
		String rawResponse = sendToGeminiAPI(prompt);

		return parseGeminiResponse(rawResponse);
	}

	public String generateDailyEmailReport(String userId, LocalDate date) {
		logger.info("Generating daily email report for user: {} on date: {}", userId, date);

		User user = getCurrentUser();

		if (apiKey == null || apiKey.isEmpty() || apiKey.equals("SUA_KEY_AQUI")) {
			logger.error("Gemini API Key is not configured");
			throw new RuntimeException("Gemini API Key is not configured");
		}

		DailyDataBundle dailyData = dailyDataAggregator.aggregateDailyData(user.getId(), date);
		String prompt = createComprehensivePrompt(dailyData, date);
		String emailContent = sendToGeminiAPI(prompt);

		emailContent = emailContent.replaceAll("```[a-z]*\\s*", "").replaceAll("```\\s*", "").trim();

		logger.info("Email report generated successfully for user: {}", userId);

		return emailContent;
	}

	private String createComprehensivePrompt(DailyDataBundle data, LocalDate reportDate) {
		StringBuilder prompt = new StringBuilder();

		prompt.append(
				"Você é um assistente de saúde e bem-estar pessoal especializado em análise holística de dados de saúde. ")
				.append("Sua tarefa é gerar um relatório diário completo e personalizado que será enviado por email para o usuário.\n\n");

		prompt.append("=== PERFIL DO USUÁRIO ===\n").append("Nome: ").append(data.getUser().getName()).append("\n")
				.append("Idade: ").append(calculateAge(data.getUser().getBirthDate())).append(" anos\n")
				.append("Data do Relatório: ").append(reportDate.toString()).append("\n\n");

		prompt.append("=== BEM-ESTAR MENTAL E EMOCIONAL ===\n");
		if (data.getWellness() != null) {
			prompt.append("Estado de Humor: ").append(data.getWellness().getMood()).append("\n");
			if (data.getWellness().getPeriod() != null) {
				prompt.append("Ciclo Menstrual: ").append(data.getWellness().getPeriod()).append("\n");
			}
			if (data.getWellness().getNote() != null && !data.getWellness().getNote().isEmpty()) {
				prompt.append("Observações Pessoais: ").append(data.getWellness().getNote()).append("\n");
			}
		} else {
			prompt.append("Nenhum registro de bem-estar emocional hoje.\n");
		}
		prompt.append("\n");

		prompt.append("=== ALIMENTAÇÃO E NUTRIÇÃO ===\n");
		if (data.getNutritionalEntries() != null && !data.getNutritionalEntries().isEmpty()) {
			int totalCalories = 0;
			double totalProtein = 0, totalCarbs = 0, totalFat = 0;

			prompt.append("Refeições registradas:\n");
			for (NutritionalEntry entry : data.getNutritionalEntries()) {
				prompt.append("  • ").append(entry.getFoodName()).append(" - ").append(entry.getCalories())
						.append(" kcal").append(" (P: ").append(entry.getProtein()).append("g").append(", C: ")
						.append(entry.getCarbs()).append("g").append(", G: ").append(entry.getFat()).append("g)\n");

				totalCalories += entry.getCalories();
				totalProtein += entry.getProtein();
				totalCarbs += entry.getCarbs();
				totalFat += entry.getFat();
			}
			prompt.append("\nTotal Diário:\n").append("  • Calorias: ").append(totalCalories).append(" kcal\n")
					.append("  • Proteínas: ").append(String.format("%.1f", totalProtein)).append("g\n")
					.append("  • Carboidratos: ").append(String.format("%.1f", totalCarbs)).append("g\n")
					.append("  • Gorduras: ").append(String.format("%.1f", totalFat)).append("g\n");
		} else {
			prompt.append("Nenhuma refeição registrada hoje.\n");
		}
		prompt.append("\n");

		prompt.append("=== ATIVIDADES FÍSICAS ===\n");
		boolean hasActivity = false;

		if (data.getPhysicalActivities() != null && !data.getPhysicalActivities().isEmpty()) {
			hasActivity = true;
			int totalMinutes = 0;
			int totalCaloriesBurned = 0;

			prompt.append("Exercícios realizados:\n");
			for (PhysicalActivityEntity activity : data.getPhysicalActivities()) {
				prompt.append("  • ").append(activity.getActivityType()).append(" - ")
						.append(activity.getDurationMinutes()).append(" minutos");
				if (activity.getCaloriesBurned() != null) {
					prompt.append(" (").append(activity.getCaloriesBurned()).append(" kcal queimadas)");
					totalCaloriesBurned += activity.getCaloriesBurned();
				}
				prompt.append("\n");
				totalMinutes += activity.getDurationMinutes();
			}
			prompt.append("Total de exercícios: ").append(totalMinutes).append(" minutos, ").append(totalCaloriesBurned)
					.append(" kcal queimadas\n\n");
		}

		if (data.getWalkingSessions() != null && !data.getWalkingSessions().isEmpty()) {
			hasActivity = true;
			int totalSteps = 0;
			double totalDistance = 0;
			int totalWalkMinutes = 0;

			prompt.append("Caminhadas registradas:\n");
			for (WalkingSession walk : data.getWalkingSessions()) {
				prompt.append("  • ").append(walk.getSteps() != null ? walk.getSteps() : 0).append(" passos")
						.append(" - ")
						.append(walk.getDistanceKm() != null ? String.format("%.2f", walk.getDistanceKm()) : "0")
						.append(" km").append(" - ")
						.append(walk.getDurationMinutes() != null ? walk.getDurationMinutes() : 0).append(" minutos\n");

				totalSteps += (walk.getSteps() != null ? walk.getSteps() : 0);
				totalDistance += (walk.getDistanceKm() != null ? walk.getDistanceKm() : 0);
				totalWalkMinutes += (walk.getDurationMinutes() != null ? walk.getDurationMinutes() : 0);
			}
			prompt.append("Total de caminhadas: ").append(totalSteps).append(" passos, ")
					.append(String.format("%.2f", totalDistance)).append(" km, ").append(totalWalkMinutes)
					.append(" minutos\n\n");
		}

		if (data.getExerciseGoals() != null) {
			prompt.append("Progresso das Metas:\n");

			if (data.getExerciseGoals().getTargetSteps() != null && data.getExerciseGoals().getTargetSteps() > 0) {
				int currentSteps = data.getExerciseGoals().getCurrentSteps() != null
						? data.getExerciseGoals().getCurrentSteps()
						: 0;
				int targetSteps = data.getExerciseGoals().getTargetSteps();
				int percentSteps = (int) ((currentSteps * 100.0) / targetSteps);
				prompt.append("  • Passos: ").append(currentSteps).append("/").append(targetSteps).append(" (")
						.append(percentSteps).append("%)\n");
			}

			if (data.getExerciseGoals().getTargetMinutes() != null && data.getExerciseGoals().getTargetMinutes() > 0) {
				int currentMinutes = data.getExerciseGoals().getCurrentMinutes() != null
						? data.getExerciseGoals().getCurrentMinutes()
						: 0;
				int targetMinutes = data.getExerciseGoals().getTargetMinutes();
				int percentMinutes = (int) ((currentMinutes * 100.0) / targetMinutes);
				prompt.append("  • Minutos de Atividade: ").append(currentMinutes).append("/").append(targetMinutes)
						.append(" (").append(percentMinutes).append("%)\n");
			}

			if (data.getExerciseGoals().getTargetCalories() != null
					&& data.getExerciseGoals().getTargetCalories() > 0) {
				int currentCalories = data.getExerciseGoals().getCurrentCalories() != null
						? data.getExerciseGoals().getCurrentCalories()
						: 0;
				int targetCalories = data.getExerciseGoals().getTargetCalories();
				int percentCalories = (int) ((currentCalories * 100.0) / targetCalories);
				prompt.append("  • Calorias Queimadas: ").append(currentCalories).append("/").append(targetCalories)
						.append(" (").append(percentCalories).append("%)\n");
			}
		}

		if (!hasActivity && (data.getExerciseGoals() == null || data.getExerciseGoals().getTargetSteps() == null)) {
			prompt.append("Nenhuma atividade física registrada hoje.\n");
		}
		prompt.append("\n");

		prompt.append("=== GESTÃO DE MEDICAMENTOS ===\n");
		if (data.getMedicines() != null && !data.getMedicines().isEmpty()) {
			prompt.append("Medicamentos prescritos:\n");
			data.getMedicines().forEach(medicine -> {
				prompt.append("  • ").append(medicine.getName()).append(" - ").append(medicine.getDose()).append("\n");
			});

			if (data.getMedicationTasks() != null && !data.getMedicationTasks().isEmpty()) {
				int taken = 0;
				int total = data.getMedicationTasks().size();

				prompt.append("\nAderência do dia:\n");
				for (MedicationTask task : data.getMedicationTasks()) {
					String status = task.isTaken() ? "✓ Tomado" : "✗ Não tomado";
					prompt.append("  • ").append(task.getMedicine().getName()).append(" às ")
							.append(task.getScheduledTime()).append(" - ").append(status).append("\n");
					if (task.isTaken())
						taken++;
				}

				int adherencePercent = (int) ((taken * 100.0) / total);
				prompt.append("\nTaxa de Adesão: ").append(taken).append("/").append(total).append(" (")
						.append(adherencePercent).append("%)\n");
			}
		} else {
			prompt.append("Nenhum medicamento prescrito.\n");
		}
		prompt.append("\n");

		prompt.append("=== CONSULTAS E COMPROMISSOS MÉDICOS ===\n");
		if (data.getAppointments() != null && !data.getAppointments().isEmpty()) {
			data.getAppointments().forEach(appointment -> {
				String status = appointment.isCompleted() ? "Realizada" : "Agendada";
				prompt.append("  • ").append(appointment.getTitle()).append(" (").append(appointment.getType())
						.append(")\n").append("    Horário: ").append(appointment.getDate()).append("\n")
						.append("    Local: ").append(appointment.getLocation()).append("\n").append("    Status: ")
						.append(status).append("\n");
			});
		} else {
			prompt.append("Nenhuma consulta agendada para hoje.\n");
		}
		prompt.append("\n");

		prompt.append("=== ATIVIDADES COGNITIVAS E LAZER ===\n");
		boolean hasCognitiveActivity = false;

		if (data.getReadingActivities() != null && !data.getReadingActivities().isEmpty()) {
			hasCognitiveActivity = true;
			prompt.append("📚 Leitura:\n");
			data.getReadingActivities().forEach(reading -> {
				int progress = reading.getTotalPages() > 0
						? (int) ((reading.getCurrentPage() * 100.0) / reading.getTotalPages())
						: 0;
				String status = reading.getIsCompleted() ? "Concluído" : progress + "% completo";
				prompt.append("  • ").append(reading.getBookTitle()).append(" - Página ")
						.append(reading.getCurrentPage()).append(" de ").append(reading.getTotalPages()).append(" (")
						.append(status).append(")\n");
			});
		}

		if (data.getCrosswordActivities() != null && !data.getCrosswordActivities().isEmpty()) {
			hasCognitiveActivity = true;
			prompt.append("\n🧩 Palavras Cruzadas:\n");
			data.getCrosswordActivities().forEach(crossword -> {
				String status = crossword.getIsCompleted() ? "Completado" : "Em progresso";
				prompt.append("  • ").append(crossword.getPuzzleName()).append(" (").append(crossword.getDifficulty())
						.append(")").append(" - ").append(crossword.getTimeSpentMinutes()).append(" minutos")
						.append(" - ").append(status).append("\n");
			});
		}

		if (data.getMovieActivities() != null && !data.getMovieActivities().isEmpty()) {
			hasCognitiveActivity = true;
			prompt.append("\n🎬 Filmes:\n");
			data.getMovieActivities().forEach(movie -> {
				String status = movie.getIsWatched() ? "Assistido" : "Na lista";
				prompt.append("  • ").append(movie.getMovieTitle());
				if (movie.getGenre() != null) {
					prompt.append(" (").append(movie.getGenre()).append(")");
				}
				if (movie.getIsWatched() && movie.getRating() != null) {
					prompt.append(" - Avaliação: ").append(movie.getRating()).append("/5");
				}
				prompt.append(" - ").append(status).append("\n");
			});
		}

		if (!hasCognitiveActivity) {
			prompt.append("Nenhuma atividade cognitiva ou de lazer registrada hoje.\n");
		}
		prompt.append("\n");

		prompt.append("=== INSTRUÇÕES PARA ANÁLISE ===\n").append(
				"Com base em TODOS os dados acima, gere um relatório de bem-estar completo e personalizado em formato de EMAIL.\n\n")
				.append("O relatório deve incluir:\n\n").append("1. SAUDAÇÃO PERSONALIZADA\n")
				.append("   - Cumprimente o usuário pelo nome de forma calorosa\n\n")
				.append("2. RESUMO EXECUTIVO DO DIA\n")
				.append("   - Uma visão geral dos principais destaques e conquistas do dia\n")
				.append("   - Identificar padrões positivos e áreas de atenção\n\n")
				.append("3. ANÁLISE DETALHADA POR ÁREA\n").append("   a) Saúde Física e Exercícios\n")
				.append("      - Avaliar o nível de atividade física\n")
				.append("      - Progresso em relação às metas\n")
				.append("      - Calorias queimadas vs. consumidas\n\n").append("   b) Nutrição e Alimentação\n")
				.append("      - Balanço calórico e distribuição de macronutrientes\n")
				.append("      - Qualidade das escolhas alimentares\n")
				.append("      - Sugestões para melhorar a nutrição\n\n").append("   c) Bem-estar Mental e Emocional\n")
				.append("      - Análise do estado de humor\n")
				.append("      - Correlação entre atividades e bem-estar emocional\n\n")
				.append("   d) Adesão ao Tratamento Médico\n").append("      - Taxa de adesão aos medicamentos\n")
				.append("      - Importância da consistência\n")
				.append("      - Lembretes sobre consultas agendadas\n\n")
				.append("   e) Engajamento Cognitivo e Social\n")
				.append("      - Atividades de estimulação mental realizadas\n")
				.append("      - Importância do equilíbrio entre atividades\n\n")
				.append("4. RECOMENDAÇÕES PERSONALIZADAS\n")
				.append("   - 3 a 5 recomendações específicas e acionáveis\n")
				.append("   - Baseadas nos dados do dia e nas áreas que precisam de atenção\n")
				.append("   - Priorize recomendações realistas e graduais\n\n").append("5. MENSAGEM MOTIVACIONAL\n")
				.append("   - Reconheça os esforços e conquistas do usuário\n")
				.append("   - Incentive a continuidade dos bons hábitos\n")
				.append("   - Termine com uma nota positiva e encorajadora\n\n").append("6. ASSINATURA\n")
				.append("   - Despedida cordial\n").append("   - Lembrete sobre quando será o próximo relatório\n\n")
				.append("FORMATAÇÃO IMPORTANTE:\n").append("- Use uma linguagem empática, acolhedora e profissional\n")
				.append("- Todo o texto deve estar em português brasileiro\n")
				.append("- Use emojis moderadamente para tornar o email mais amigável\n")
				.append("- Estruture o texto com parágrafos claros e espaçamento adequado\n")
				.append("- Use marcadores (•) ou numeração quando apropriado\n")
				.append("- Seja específico citando números e dados reais do usuário\n")
				.append("- Mantenha um tom positivo mesmo ao abordar áreas de melhoria\n")
				.append("- O email deve ser completo mas conciso (não muito longo)\n\n")
				.append("RETORNE APENAS O TEXTO DO EMAIL, SEM JSON, SEM MARKDOWN, SEM CÓDIGO.\n")
				.append("O texto deve estar pronto para ser enviado diretamente por email.");

		return prompt.toString();
	}

	private String createStructuredPromptForJson(DailyDataBundle data, LocalDate reportDate) {
		StringBuilder prompt = new StringBuilder();

		prompt.append("Act as a personal health and wellness assistant. ")
				.append("Analyze the following comprehensive daily data and provide a structured wellness report:\n\n");

		prompt.append("USER PROFILE:\n").append("- Name: ").append(data.getUser().getName()).append("\n")
				.append("- Age: ").append(calculateAge(data.getUser().getBirthDate())).append("\n")
				.append("- Report Date: ").append(reportDate.toString()).append("\n\n");

		if (data.getWellness() != null) {
			prompt.append("WELLNESS & MENTAL HEALTH:\n").append("- Mood: ").append(data.getWellness().getMood())
					.append("\n").append("- Period: ").append(data.getWellness().getPeriod()).append("\n")
					.append("- Notes: ")
					.append(data.getWellness().getNote() != null ? data.getWellness().getNote() : "None")
					.append("\n\n");
		} else {
			prompt.append("WELLNESS & MENTAL HEALTH:\n").append("- No wellness data recorded for this date\n\n");
		}

		prompt.append("NUTRITIONAL INTAKE:\n");
		if (data.getNutritionalEntries() != null && !data.getNutritionalEntries().isEmpty()) {
			data.getNutritionalEntries().forEach(entry -> {
				prompt.append("- ").append(entry.getFoodName()).append(" | Calories: ").append(entry.getCalories())
						.append(" | Protein: ").append(entry.getProtein()).append("g").append(" | Carbs: ")
						.append(entry.getCarbs()).append("g").append(" | Fat: ").append(entry.getFat()).append("g\n");
			});
		} else {
			prompt.append("- No nutritional entries recorded for this date\n");
		}
		prompt.append("\n");

		prompt.append("PHYSICAL ACTIVITIES:\n");
		if (data.getPhysicalActivities() != null && !data.getPhysicalActivities().isEmpty()) {
			data.getPhysicalActivities().forEach(activity -> {
				prompt.append("- ").append(activity.getActivityType()).append(" | Duration: ")
						.append(activity.getDurationMinutes()).append("min").append(" | Calories Burned: ")
						.append(activity.getCaloriesBurned() != null ? activity.getCaloriesBurned() : 0).append("\n");
			});
		} else {
			prompt.append("- No physical activities recorded for this date\n");
		}
		prompt.append("\n");

		prompt.append("WALKING SESSIONS:\n");
		if (data.getWalkingSessions() != null && !data.getWalkingSessions().isEmpty()) {
			data.getWalkingSessions().forEach(walk -> {
				prompt.append("- Steps: ").append(walk.getSteps() != null ? walk.getSteps() : 0).append(" | Distance: ")
						.append(walk.getDistanceKm() != null ? walk.getDistanceKm() : 0).append("km")
						.append(" | Duration: ")
						.append(walk.getDurationMinutes() != null ? walk.getDurationMinutes() : 0).append("min\n");
			});
		} else {
			prompt.append("- No walking sessions recorded for this date\n");
		}
		prompt.append("\n");

		if (data.getExerciseGoals() != null) {
			prompt.append("EXERCISE GOALS:\n").append("- Target Steps: ")
					.append(data.getExerciseGoals().getTargetSteps() != null ? data.getExerciseGoals().getTargetSteps()
							: 0)
					.append(" | Current Steps: ")
					.append(data.getExerciseGoals().getCurrentSteps() != null
							? data.getExerciseGoals().getCurrentSteps()
							: 0)
					.append("\n").append("- Target Minutes: ")
					.append(data.getExerciseGoals().getTargetMinutes() != null
							? data.getExerciseGoals().getTargetMinutes()
							: 0)
					.append(" | Current Minutes: ")
					.append(data.getExerciseGoals().getCurrentMinutes() != null
							? data.getExerciseGoals().getCurrentMinutes()
							: 0)
					.append("\n").append("- Target Calories: ")
					.append(data.getExerciseGoals().getTargetCalories() != null
							? data.getExerciseGoals().getTargetCalories()
							: 0)
					.append(" | Current Calories: ")
					.append(data.getExerciseGoals().getCurrentCalories() != null
							? data.getExerciseGoals().getCurrentCalories()
							: 0)
					.append("\n\n");
		} else {
			prompt.append("EXERCISE GOALS:\n").append("- No exercise goals set for this date\n\n");
		}

		prompt.append("MEDICATION MANAGEMENT:\n");
		if (data.getMedicines() != null && !data.getMedicines().isEmpty()) {
			data.getMedicines().forEach(medicine -> {
				prompt.append("- ").append(medicine.getName()).append(" | Dose: ").append(medicine.getDose())
						.append("\n");
			});
		} else {
			prompt.append("- No medicines prescribed\n");
		}

		if (data.getMedicationTasks() != null && !data.getMedicationTasks().isEmpty()) {
			prompt.append("Medication Tasks:\n");
			data.getMedicationTasks().forEach(task -> {
				prompt.append("- ").append(task.getMedicine().getName()).append(" | Scheduled: ")
						.append(task.getScheduledTime()).append(" | Taken: ").append(task.isTaken() ? "YES" : "NO")
						.append("\n");
			});
		}
		prompt.append("\n");

		prompt.append("MEDICAL APPOINTMENTS:\n");
		if (data.getAppointments() != null && !data.getAppointments().isEmpty()) {
			data.getAppointments().forEach(appointment -> {
				prompt.append("- ").append(appointment.getTitle()).append(" | Type: ").append(appointment.getType())
						.append(" | Time: ").append(appointment.getDate()).append(" | Location: ")
						.append(appointment.getLocation()).append(" | Completed: ")
						.append(appointment.isCompleted() ? "YES" : "NO").append("\n");
			});
		} else {
			prompt.append("- No appointments scheduled for this date\n");
		}
		prompt.append("\n");
		prompt.append("COGNITIVE & LEISURE ACTIVITIES:\n");

		if (data.getReadingActivities() != null && !data.getReadingActivities().isEmpty()) {
			prompt.append("Reading Activities:\n");
			data.getReadingActivities().forEach(reading -> {
				prompt.append("- Book: ").append(reading.getBookTitle()).append(" | Progress: ")
						.append(reading.getCurrentPage()).append("/").append(reading.getTotalPages())
						.append(" | Completed: ").append(reading.getIsCompleted() ? "YES" : "NO").append("\n");
			});
		} else {
			prompt.append("- No reading activities for this date\n");
		}

		if (data.getCrosswordActivities() != null && !data.getCrosswordActivities().isEmpty()) {
			prompt.append("Crossword Activities:\n");
			data.getCrosswordActivities().forEach(crossword -> {
				prompt.append("- Puzzle: ").append(crossword.getPuzzleName()).append(" | Difficulty: ")
						.append(crossword.getDifficulty()).append(" | Time Spent: ")
						.append(crossword.getTimeSpentMinutes()).append("min").append(" | Completed: ")
						.append(crossword.getIsCompleted() ? "YES" : "NO").append("\n");
			});
		} else {
			prompt.append("- No crossword activities for this date\n");
		}

		if (data.getMovieActivities() != null && !data.getMovieActivities().isEmpty()) {
			prompt.append("Movie Activities:\n");
			data.getMovieActivities().forEach(movie -> {
				prompt.append("- Movie: ").append(movie.getMovieTitle()).append(" | Genre: ")
						.append(movie.getGenre() != null ? movie.getGenre() : "Not specified").append(" | Rating: ")
						.append(movie.getRating()).append("/5").append(" | Watched: ")
						.append(movie.getIsWatched() ? "YES" : "NO").append("\n");
			});
		} else {
			prompt.append("- No movie activities for this date\n");
		}
		prompt.append("\n");

		prompt.append("ANALYSIS REQUEST:\n").append("Please provide a comprehensive wellness report including:\n")
				.append("1. Overall daily assessment and achievements\n")
				.append("2. Health and wellness patterns observed\n").append("3. Medication adherence analysis\n")
				.append("4. Physical activity evaluation\n").append("5. Nutritional balance assessment\n")
				.append("6. Mental and cognitive engagement review\n")
				.append("7. Specific recommendations for improvement\n").append("8. Motivation and encouragement\n\n")
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

			ResponseEntity<GeminiApiResponse> response = restTemplate.postForEntity(url, entity,
					GeminiApiResponse.class);

			if (response.getBody() != null && response.getBody().getCandidates() != null
					&& !response.getBody().getCandidates().isEmpty()) {
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
			String cleanedResponse = rawResponse.replaceAll("```json\\s*", "").replaceAll("```\\s*", "").trim();

			logger.info("Cleaned response: {}", cleanedResponse);

			JsonNode jsonNode = objectMapper.readTree(cleanedResponse);

			GeminiReportResponse response = GeminiReportResponse.builder()
					.overallAssessment(getJsonField(jsonNode, "overall_assessment"))
					.medicationAdherence(getJsonField(jsonNode, "medication_adherence"))
					.activityEvaluation(getJsonField(jsonNode, "activity_evaluation"))
					.nutritionAnalysis(getJsonField(jsonNode, "nutrition_analysis"))
					.cognitiveInsights(getJsonField(jsonNode, "cognitive_insights"))
					.motivationalMessage(getJsonField(jsonNode, "motivational_message"))
					.generatedAt(LocalDateTime.now()).build();

			if (jsonNode.has("recommendations")) {
				JsonNode recommendationsNode = jsonNode.get("recommendations");
				if (recommendationsNode.isArray()) {
					List<String> recommendations = objectMapper.convertValue(recommendationsNode, List.class);
					response.setRecommendations(recommendations);
				}
			}

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

			return GeminiReportResponse.builder().overallAssessment(rawResponse).generatedAt(LocalDateTime.now())
					.build();
		}
	}

	private String getJsonField(JsonNode jsonNode, String fieldName) {
		return jsonNode.has(fieldName) ? jsonNode.get(fieldName).asText() : null;
	}

	private int calculateAge(LocalDate birthDate) {
		if (birthDate == null)
			return 0;
		return LocalDate.now().getYear() - birthDate.getYear();
	}

	public String generateReport(Long userId, LocalDate startDate, LocalDate endDate) {
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

	static class GeminiApiResponse {
		private List<Candidate> candidates;

		public List<Candidate> getCandidates() {
			return candidates;
		}

		public void setCandidates(List<Candidate> candidates) {
			this.candidates = candidates;
		}

		static class Candidate {
			private Content content;

			public Content getContent() {
				return content;
			}

			public void setContent(Content content) {
				this.content = content;
			}
		}

		static class Content {
			private List<Part> parts;

			public List<Part> getParts() {
				return parts;
			}

			public void setParts(List<Part> parts) {
				this.parts = parts;
			}
		}

		static class Part {
			private String text;

			public String getText() {
				return text;
			}

			public void setText(String text) {
				this.text = text;
			}
		}
	}
}