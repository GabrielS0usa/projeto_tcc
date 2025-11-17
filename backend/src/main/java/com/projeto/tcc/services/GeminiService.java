package com.projeto.tcc.services;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.projeto.tcc.entities.Medicine;
import com.projeto.tcc.entities.PhysicalActivityEntity;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.entities.Wellness;
import com.projeto.tcc.repositories.MedicineRepository;
import com.projeto.tcc.repositories.PhysicalActivityRepository;
import com.projeto.tcc.repositories.ReadingActivityRepository;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.repositories.WellnessRepository;
import com.projeto.tcc.services.exceptions.ResourceNotFoundException;

@Service
public class GeminiService {

	private static final Logger logger = LoggerFactory.getLogger(GeminiService.class);

	@Value("${gemini.api.url}")
	private String geminiApiUrl;

	@Value("${gemini.api.key}")
	private String apiKey;

	private final RestTemplate restTemplate;
	private final UserRepository userRepository;
	private final WellnessRepository wellnessRepository;
	private final MedicineRepository medicineRepository;
	private final PhysicalActivityRepository physicalActivityRepository;
	private final ReadingActivityRepository readingRepository;

	@Autowired
	public GeminiService(RestTemplate restTemplate, UserRepository userRepository,
			WellnessRepository wellnessRepository, MedicineRepository medicineRepository,
			PhysicalActivityRepository physicalActivityRepository, ReadingActivityRepository readingRepository) {
		this.restTemplate = restTemplate;
		this.userRepository = userRepository;
		this.wellnessRepository = wellnessRepository;
		this.medicineRepository = medicineRepository;
		this.physicalActivityRepository = physicalActivityRepository;
		this.readingRepository = readingRepository;
	}

	public String generateReport(Long userId, LocalDate startDate, LocalDate endDate) {
		User user = userRepository.findById(userId)
				.orElseThrow(() -> new ResourceNotFoundException("Usuário não encontrado com id: " + userId));

		if (apiKey == null || apiKey.isEmpty() || apiKey.equals("SUA_KEY_AQUI")) {
			logger.error("API Key do Gemini não está configurada.");
			return "Erro: API Key do Gemini não configurada.";
		}

		logger.info("Construindo prompt para usuário: {}", user.getName());
		String prompt = buildPrompt(user, startDate, endDate);

		logger.info("Chamando API Gemini...");
		return callGemini(prompt);
	}

	private String buildPrompt(User user, LocalDate start, LocalDate end) {
		StringBuilder sb = new StringBuilder();
		sb.append(
				"Você é um assistente de saúde e bem-estar. Seu objetivo é analisar os dados de um paciente, que podem incluir informações sobre medicamentos, bem-estar emocional, atividades físicas e cognitivas.");
		sb.append(
				"Gere um relatório em português do Brasil, em tom profissional e empático, para o cuidador do paciente.\n");
		sb.append("Analise os dados do paciente ").append(user.getName()).append(" fornecidos para o período de ")
				.append(start).append(" até ").append(end).append(":\n\n");

		List<Medicine> medicines = medicineRepository.findByUser(user);
		sb.append("=== MEDICAMENTOS PRESCRITOS ===\n");
		if (medicines.isEmpty()) {
			sb.append("Nenhum medicamento registrado.\n");
		} else {
			medicines.forEach(
					m -> sb.append("- ").append(m.getName()).append(" (Dose: ").append(m.getDose()).append(")\n"));
		}

		List<Wellness> wellnessEntries = wellnessRepository.findByUserAndEntryDateBetween(user, start, end);
		sb.append("\n=== BEM-ESTAR EMOCIONAL (período selecionado) ===\n");
		if (wellnessEntries.isEmpty()) {
			sb.append("Nenhum registro de bem-estar emocional encontrado no período.\n");
		} else {
			Map<String, Long> moodCounts = wellnessEntries.stream().map(Wellness::getMood).filter(Objects::nonNull)
					.map(Object::toString).collect(Collectors.groupingBy(s -> s, Collectors.counting()));

			sb.append("Resumo de humores registrados:\n");
			moodCounts.forEach(
					(mood, count) -> sb.append("- ").append(mood).append(": ").append(count).append(" vez(es)\n"));
		}

		List<PhysicalActivityEntity> activities = physicalActivityRepository.findByUserAndDateBetween(user, start, end);
		sb.append("\n=== ATIVIDADES FÍSICAS (período selecionado) ===\n");
		if (activities.isEmpty()) {
			sb.append("Nenhuma atividade física registrada no período.\n");
		} else {
			activities.forEach(a -> sb.append("- ").append(a.getDate()).append(": ").append(a.getActivityType())
					.append(" - Duração: ").append(a.getDurationMinutes()).append(" minutos.\n"));
		}

		Long booksRead = readingRepository.countCompletedByUser(user);
		sb.append("\n=== ATIVIDADES COGNITIVAS ===\n");
		sb.append("- Total de livros lidos (histórico): ").append(booksRead).append("\n");

		sb.append("\n\nCom base estritamente nos dados fornecidos, gere um relatório com as seguintes seções:\n");
		sb.append("1. **Resumo Geral:** Uma breve visão geral da saúde do paciente no período.\n");
		sb.append("2. **Pontos Positivos:** Destaque áreas onde o paciente está indo bem.\n");
		sb.append("3. **Áreas de Atenção:** Identifique padrões preocupantes.\n");
		sb.append("4. **Recomendações para o Cuidador:** Sugestões práticas com base nos dados.\n");

		logger.debug("Prompt gerado: {}", sb.toString());
		return sb.toString();
	}

	private String callGemini(String prompt) {
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

			ResponseEntity<GeminiResponse> response = restTemplate.postForEntity(url, entity, GeminiResponse.class);

			String generatedText = response.getBody().getCandidates().get(0).getContent().getParts().get(0).getText();

			return generatedText;

		} catch (RestClientException e) {
			logger.error("Erro ao chamar a API Gemini: {}", e.getMessage(), e);
			return "Erro ao gerar relatório: Falha na comunicação com a API de IA.";
		} catch (Exception e) {
			logger.error("Erro inesperado no GeminiService: {}", e.getMessage(), e);
			return "Erro ao gerar relatório: Falha interna ao processar a resposta da IA.";
		}
	}

	static class GeminiResponse {
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
			private String role;

			public List<Part> getParts() {
				return parts;
			}

			public void setParts(List<Part> parts) {
				this.parts = parts;
			}

			public String getRole() {
				return role;
			}

			public void setRole(String role) {
				this.role = role;
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