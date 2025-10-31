package com.projeto.tcc.services;

import java.time.LocalDate;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.projeto.tcc.dto.ProgressDTO;
import com.projeto.tcc.dto.UserProfileDTO;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.entities.Wellness; 
import com.projeto.tcc.repositories.MedicationTaskRepository;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.repositories.WellnessRepository; 

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;
    @Autowired
    private MedicationTaskRepository medicationTaskRepository; 
    @Autowired
    private WellnessRepository wellnessRepository; 
    @Autowired
    private MedicineService medicineService; 

    public UserProfileDTO getUserProfile() {
        User user = getCurrentUser();
        return new UserProfileDTO(user.getName());
    }

    public ProgressDTO getTodayProgress() {
        User user = getCurrentUser();
        LocalDate today = LocalDate.now();

        List<com.projeto.tcc.dto.MedicationTaskDTO> medicineTasks = medicineService.findTodayTasks();
        int totalMedicineTasks = medicineTasks.size();
        int completedMedicineTasks = (int) medicineTasks.stream().filter(com.projeto.tcc.dto.MedicationTaskDTO::taken).count();

        List<Wellness> wellnessEntries = wellnessRepository.findByUserAndEntryDate(user, today); 
        int totalWellnessTasks = 3; 
        int completedWellnessTasks = wellnessEntries.size(); 

        int totalTasks = totalMedicineTasks + totalWellnessTasks;
        int completedTasks = completedMedicineTasks + completedWellnessTasks;

        if (totalMedicineTasks == 0 && completedMedicineTasks == 0 && wellnessEntries.isEmpty()) {
            totalTasks = 0;
            completedTasks = 0;
        }
        return new ProgressDTO(completedTasks, totalTasks);
    }

    public User getCurrentUser() {
         String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado para o token atual"));
    }
}

