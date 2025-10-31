package com.projeto.tcc.services;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.projeto.tcc.dto.WellnessEntryDTO;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.entities.Wellness;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.repositories.WellnessRepository;

@Service
public class WellnessService {

    @Autowired private WellnessRepository repository;
    @Autowired private UserRepository userRepository;

    public void save(WellnessEntryDTO dto) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        LocalDate today = LocalDate.now();

        repository.findByUserAndEntryDateAndPeriod(user, today, dto.period())
            .ifPresent(entry -> {
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

        return entries.stream()
                .map(entry -> new WellnessEntryDTO(entry.getMood(), entry.getPeriod(), entry.getNote()))
                .collect(Collectors.toList());
    }
}