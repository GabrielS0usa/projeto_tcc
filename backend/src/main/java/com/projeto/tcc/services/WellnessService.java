package com.projeto.tcc.services;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.projeto.tcc.dto.GeminiReportResponse;
import com.projeto.tcc.dto.WellnessEntryDTO;
import com.projeto.tcc.entities.Consent;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.entities.Wellness;
import com.projeto.tcc.repositories.ConsentRepository;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.repositories.WellnessRepository;

import jakarta.transaction.Transactional;

@Service
public class WellnessService {

	@Autowired
	private WellnessRepository repository;
	@Autowired
	private UserRepository userRepository;
	@Autowired
	private EmailService emailService;
	@Autowired
	ConsentRepository consentRepository;
	@Autowired
    private GeminiServiceNew geminiService;

	public void save(WellnessEntryDTO dto) {
		String email = SecurityContextHolder.getContext().getAuthentication().getName();
		User user = userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

		LocalDate today = LocalDate.now();

		repository.findByUserAndEntryDateAndPeriod(user, today, dto.period()).ifPresent(entry -> {
			throw new IllegalStateException("Um registro para este período já foi salvo hoje.");
		});

		Wellness entity = new Wellness();
		entity.setUser(user);
		entity.setMood(dto.mood());
		entity.setPeriod(dto.period());
		entity.setNote(dto.note());
		entity.setEntryDate(today);

		repository.save(entity);
	}

	public List<WellnessEntryDTO> findTodayEntries() {
		String email = SecurityContextHolder.getContext().getAuthentication().getName();
		User user = userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

		List<Wellness> entries = repository.findByUserAndEntryDate(user, LocalDate.now());

		return entries.stream().map(entry -> new WellnessEntryDTO(entry.getMood(), entry.getPeriod(), entry.getNote()))
				.collect(Collectors.toList());
	}
	
	@Transactional
	public GeminiReportResponse generateAndProcessDailyReport(String userId, LocalDate date) {
	    GeminiReportResponse report = geminiService.generateDailyReport(userId.toString(), date);
	    
	    if (report.getRecommendations() != null) {
	        @SuppressWarnings("unchecked")
	        List<Object> rawList = (List<Object>) (List<?>) report.getRecommendations();
	        
	        List<String> stringRecommendations = rawList.stream()
	            .map(rec -> {
	                if (rec instanceof String) {
	                    return (String) rec;
	                } else if (rec instanceof Map) {
	                    @SuppressWarnings("unchecked")
	                    Map<String, Object> map = (Map<String, Object>) rec;
	                    return map.toString();
	                } else {
	                    return rec != null ? rec.toString() : "";
	                }
	            })
	            .collect(Collectors.toList());
	        
	        report.setRecommendations(stringRecommendations);
	    }

	    try {
	        notifyCaregiverIfAuthorized(Long.valueOf(userId), report);
	    } catch (Exception e) {
	        System.err.println("Aviso: Falha ao tentar notificar cuidador. " + e.getMessage());
	        e.printStackTrace();
	    }

	    return report;
	}
	
	@Transactional
	private void notifyCaregiverIfAuthorized(Long userId, GeminiReportResponse report) {
		Optional<Consent> consentOpt = consentRepository.findByUserIdWithCaregiver(userId);

		if (consentOpt.isPresent()) {
			Consent consent = consentOpt.get();
			if (consent.isActive() && consent.isDataSharing() && consent.getCaregiver() != null) {

				String userName = userRepository.findById(userId).map(User::getName).orElse("Usuário");

				String emailBody = formatReportForEmail(report); 
				

				emailService.sendCaregiverReport(consent.getCaregiver().getEmail(), consent.getCaregiver().getName(),
						userName, emailBody);
			}
		}
	}

	private String formatReportForEmail(GeminiReportResponse report) {
	    StringBuilder sb = new StringBuilder();
	    
	    sb.append("<strong>Avaliação Geral:</strong><br>");
	    sb.append(report.getOverallAssessment() != null ? report.getOverallAssessment() : "N/A").append("<br><br>");
	    
	    sb.append("<strong>Recomendações:</strong><br>");
	    if (report.getRecommendations() != null && !report.getRecommendations().isEmpty()) {
	        for (Object rec : report.getRecommendations()) {
	            String recText;
	            
	            // Verifica o tipo do objeto
	            if (rec instanceof String) {
	                recText = (String) rec;
	            } else if (rec instanceof Map) {
	                // Se for um Map, tenta extrair algum valor relevante
	                @SuppressWarnings("unchecked")
	                Map<String, Object> recMap = (Map<String, Object>) rec;
	                recText = recMap.toString(); // ou extrai campos específicos
	            } else {
	                recText = rec != null ? rec.toString() : "";
	            }
	            
	            sb.append("• ").append(recText).append("<br>");
	        }
	    } else {
	        sb.append("Nenhuma recomendação disponível.<br>");
	    }
	    
	    sb.append("<br><strong>Mensagem Motivacional:</strong><br>");
	    sb.append(report.getMotivationalMessage() != null ? report.getMotivationalMessage() : "N/A");
	    
	    return sb.toString();
	}
}