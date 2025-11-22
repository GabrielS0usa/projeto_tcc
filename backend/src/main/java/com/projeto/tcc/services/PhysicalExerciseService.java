package com.projeto.tcc.services;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.projeto.tcc.dto.DailyExerciseGoalDTO;
import com.projeto.tcc.dto.PhysicalActivityDTO;
import com.projeto.tcc.dto.WalkingSessionDTO;
import com.projeto.tcc.dto.WalkingStartDTO;
import com.projeto.tcc.dto.WeeklyExerciseSummaryDTO;
import com.projeto.tcc.entities.DailyExerciseGoal;
import com.projeto.tcc.entities.PhysicalActivityEntity;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.entities.WalkingSession;
import com.projeto.tcc.repositories.DailyExerciseGoalRepository;
import com.projeto.tcc.repositories.PhysicalActivityRepository;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.repositories.WalkingSessionRepository;

@Service
public class PhysicalExerciseService {

    @Autowired
    private WalkingSessionRepository walkingSessionRepository;

    @Autowired
    private PhysicalActivityRepository physicalActivityRepository;

    @Autowired
    private DailyExerciseGoalRepository dailyExerciseGoalRepository;

    @Autowired
    private UserRepository userRepository;

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
    }

    // ==================== Walking Session Methods ====================

    @Transactional
    public WalkingStartDTO startWalkingSession() {
        User user = getCurrentUser();
        
        walkingSessionRepository.findByUserAndIsActiveTrue(user)
                .ifPresent(session -> {
                    throw new IllegalStateException("Já existe uma sessão de caminhada ativa");
                });

        WalkingSession entity = new WalkingSession();
        entity.setUser(user);
        entity.setIsActive(true);
        entity.setStartTime(LocalDateTime.now());
        entity.setDurationMinutes(0);
        entity.setDistanceKm(0.0);
        entity.setSteps(0);
        entity.setCaloriesBurned(0);
        entity = walkingSessionRepository.save(entity);
        
        
        return new WalkingStartDTO(entity.getId(),entity.getStartTime());
    }

    @Transactional
    public WalkingSessionDTO endWalkingSession(Long id, WalkingSessionDTO dto) {
        User user = getCurrentUser();
        WalkingSession entity = walkingSessionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Sessão de caminhada não encontrada"));

        if (!entity.getUser().equals(user)) {
            throw new SecurityException("Acesso negado");
        }

        entity.setEndTime(LocalDateTime.now());
        entity.setIsActive(false);
        entity.setDurationMinutes(dto.durationMinutes());
        entity.setDistanceKm(dto.distanceKm());
        entity.setSteps(dto.steps());
        entity.setCaloriesBurned(dto.caloriesBurned());
        entity.setNotes(dto.notes());

        entity = walkingSessionRepository.save(entity);

        // Update daily goal
        updateDailyGoalFromWalking(entity);

        return new WalkingSessionDTO(entity);
    }

    @Transactional(readOnly = true)
    public WalkingSessionDTO getActiveWalkingSession() {
        User user = getCurrentUser();
        WalkingSession session = walkingSessionRepository.findByUserAndIsActiveTrue(user)
                .orElse(null);
        return session != null ? new WalkingSessionDTO(session) : null;
    }

    @Transactional(readOnly = true)
    public List<WalkingSessionDTO> getAllWalkingSessions() {
        User user = getCurrentUser();
        return walkingSessionRepository.findByUserOrderByStartTimeDesc(user)
                .stream()
                .map(WalkingSessionDTO::new)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<WalkingSessionDTO> getWalkingSessionsByDateRange(LocalDate startDate, LocalDate endDate) {
        User user = getCurrentUser();
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(LocalTime.MAX);

        return walkingSessionRepository.findByUserAndStartTimeBetweenOrderByStartTimeDesc(user, start, end)
                .stream()
                .map(WalkingSessionDTO::new)
                .collect(Collectors.toList());
    }

    @Transactional
    public void deleteWalkingSession(Long id) {
        User user = getCurrentUser();
        WalkingSession entity = walkingSessionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Sessão de caminhada não encontrada"));

        if (!entity.getUser().equals(user)) {
            throw new SecurityException("Acesso negado");
        }

        walkingSessionRepository.deleteById(id);
    }

    // ==================== Physical Activity Methods ====================

    @Transactional
    public PhysicalActivityDTO createPhysicalActivity(PhysicalActivityDTO dto) {
        User user = getCurrentUser();

        PhysicalActivityEntity entity = new PhysicalActivityEntity();
        copyPhysicalActivityDtoToEntity(dto, entity);
        entity.setUser(user);

        entity = physicalActivityRepository.save(entity);

        // Update daily goal
        updateDailyGoalFromActivity(entity);

        return new PhysicalActivityDTO(entity);
    }

    @Transactional
    public PhysicalActivityDTO updatePhysicalActivity(Long id, PhysicalActivityDTO dto) {
        User user = getCurrentUser();
        PhysicalActivityEntity entity = physicalActivityRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Atividade física não encontrada"));

        if (!entity.getUser().equals(user)) {
            throw new SecurityException("Acesso negado");
        }

        copyPhysicalActivityDtoToEntity(dto, entity);
        entity = physicalActivityRepository.save(entity);

        return new PhysicalActivityDTO(entity);
    }

    @Transactional(readOnly = true)
    public List<PhysicalActivityDTO> getAllPhysicalActivities() {
        User user = getCurrentUser();
        return physicalActivityRepository.findByUserOrderByDateDesc(user)
                .stream()
                .map(PhysicalActivityDTO::new)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PhysicalActivityDTO> getPhysicalActivitiesByDateRange(LocalDate startDate, LocalDate endDate) {
        User user = getCurrentUser();
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(LocalTime.MAX);

        return physicalActivityRepository.findByUserAndDateBetweenOrderByDateDesc(user, start, end)
                .stream()
                .map(PhysicalActivityDTO::new)
                .collect(Collectors.toList());
    }

    @Transactional
    public void deletePhysicalActivity(Long id) {
        User user = getCurrentUser();
        PhysicalActivityEntity entity = physicalActivityRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Atividade física não encontrada"));

        if (!entity.getUser().equals(user)) {
            throw new SecurityException("Acesso negado");
        }

        physicalActivityRepository.deleteById(id);
    }

    // ==================== Daily Exercise Goal Methods ====================

    @Transactional
    public DailyExerciseGoalDTO getTodayGoal() {
        User user = getCurrentUser();
        LocalDate today = LocalDate.now();

        DailyExerciseGoal goal = dailyExerciseGoalRepository.findByUserAndDate(user, today)
                .orElseGet(() -> createDefaultGoalForDate(user, today));

        return new DailyExerciseGoalDTO(goal);
    }

    @Transactional
    public DailyExerciseGoalDTO updateDailyGoal(DailyExerciseGoalDTO dto) {
        User user = getCurrentUser();
        LocalDate date = dto.date() != null ? dto.date() : LocalDate.now();

        DailyExerciseGoal goal = dailyExerciseGoalRepository.findByUserAndDate(user, date)
                .orElseGet(() -> {
                    DailyExerciseGoal newGoal = new DailyExerciseGoal();
                    newGoal.setUser(user);
                    newGoal.setDate(date);
                    return newGoal;
                });

        goal.setTargetSteps(dto.targetSteps());
        goal.setTargetMinutes(dto.targetMinutes());
        goal.setTargetCalories(dto.targetCalories());
        goal.setCurrentSteps(dto.currentSteps());
        goal.setCurrentMinutes(dto.currentMinutes());
        goal.setCurrentCalories(dto.currentCalories());

        goal = dailyExerciseGoalRepository.save(goal);
        return new DailyExerciseGoalDTO(goal);
    }

    @Transactional(readOnly = true)
    public WeeklyExerciseSummaryDTO getWeeklySummary() {
        User user = getCurrentUser();
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.minusDays(6); // Last 7 days including today

        List<DailyExerciseGoal> weeklyGoals = dailyExerciseGoalRepository
                .findByUserAndDateBetweenOrderByDateDesc(user, weekStart, today);

        int totalSteps = weeklyGoals.stream()
                .mapToInt(DailyExerciseGoal::getCurrentSteps)
                .sum();

        int totalMinutes = weeklyGoals.stream()
                .mapToInt(DailyExerciseGoal::getCurrentMinutes)
                .sum();

        int totalCalories = weeklyGoals.stream()
                .mapToInt(DailyExerciseGoal::getCurrentCalories)
                .sum();

        int activeDays = (int) weeklyGoals.stream()
                .filter(g -> g.getCurrentSteps() > 0 || g.getCurrentMinutes() > 0)
                .count();

        List<DailyExerciseGoalDTO> dailyGoalDTOs = weeklyGoals.stream()
                .map(DailyExerciseGoalDTO::new)
                .collect(Collectors.toList());

        return new WeeklyExerciseSummaryDTO(
                totalSteps,
                totalMinutes,
                totalCalories,
                activeDays,
                dailyGoalDTOs
        );
    }

    // ==================== Helper Methods ====================

    private DailyExerciseGoal createDefaultGoalForDate(User user, LocalDate date) {
        DailyExerciseGoal goal = new DailyExerciseGoal();
        goal.setUser(user);
        goal.setDate(date);
        goal.setTargetSteps(5000);
        goal.setTargetMinutes(30);
        goal.setTargetCalories(200);
        goal.setCurrentSteps(0);
        goal.setCurrentMinutes(0);
        goal.setCurrentCalories(0);

        return dailyExerciseGoalRepository.save(goal);
    }

    private void updateDailyGoalFromWalking(WalkingSession session) {
        User user = session.getUser();
        LocalDate date = session.getStartTime().toLocalDate();

        DailyExerciseGoal goal = dailyExerciseGoalRepository.findByUserAndDate(user, date)
                .orElseGet(() -> createDefaultGoalForDate(user, date));

        goal.setCurrentSteps(goal.getCurrentSteps() + session.getSteps());
        goal.setCurrentMinutes(goal.getCurrentMinutes() + session.getDurationMinutes());
        goal.setCurrentCalories(goal.getCurrentCalories() + session.getCaloriesBurned());

        dailyExerciseGoalRepository.save(goal);
    }

    private void updateDailyGoalFromActivity(PhysicalActivityEntity activity) {
        User user = activity.getUser();
        LocalDate date = activity.getDate().toLocalDate();

        DailyExerciseGoal goal = dailyExerciseGoalRepository.findByUserAndDate(user, date)
                .orElseGet(() -> createDefaultGoalForDate(user, date));

        goal.setCurrentMinutes(goal.getCurrentMinutes() + activity.getDurationMinutes());
        goal.setCurrentCalories(goal.getCurrentCalories() + activity.getCaloriesBurned());

        dailyExerciseGoalRepository.save(goal);
    }

    private void copyPhysicalActivityDtoToEntity(PhysicalActivityDTO dto, PhysicalActivityEntity entity) {
        entity.setActivityType(dto.activityType());
        entity.setActivityName(dto.activityName());
        entity.setDate(dto.date());
        entity.setDurationMinutes(dto.durationMinutes());
        entity.setCaloriesBurned(dto.caloriesBurned());
        entity.setNotes(dto.notes());
        entity.setIntensityLevel(dto.intensityLevel());
    }
}
