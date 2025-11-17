package com.projeto.tcc.services;

import java.time.LocalDate;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.projeto.tcc.dto.DailyDataBundleManual;
import com.projeto.tcc.entities.Appointment;
import com.projeto.tcc.entities.CrosswordActivity;
import com.projeto.tcc.entities.DailyExerciseGoal;
import com.projeto.tcc.entities.MedicationTask;
import com.projeto.tcc.entities.Medicine;
import com.projeto.tcc.entities.MovieActivity;
import com.projeto.tcc.entities.NutritionalEntry;
import com.projeto.tcc.entities.PhysicalActivityEntity;
import com.projeto.tcc.entities.ReadingActivity;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.entities.WalkingSession;
import com.projeto.tcc.entities.Wellness;
import com.projeto.tcc.repositories.AppointmentRepository;
import com.projeto.tcc.repositories.CrosswordActivityRepository;
import com.projeto.tcc.repositories.DailyExerciseGoalRepository;
import com.projeto.tcc.repositories.MedicationTaskRepository;
import com.projeto.tcc.repositories.MedicineRepository;
import com.projeto.tcc.repositories.MovieActivityRepository;
import com.projeto.tcc.repositories.NutritionalEntryRepository;
import com.projeto.tcc.repositories.PhysicalActivityRepository;
import com.projeto.tcc.repositories.ReadingActivityRepository;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.repositories.WalkingSessionRepository;
import com.projeto.tcc.repositories.WellnessRepository;

@Service
public class DailyDataAggregatorManual {

    private final UserRepository userRepository;
    private final WellnessRepository wellnessRepository;
    private final NutritionalEntryRepository nutritionalEntryRepository;
    private final PhysicalActivityRepository physicalActivityRepository;
    private final WalkingSessionRepository walkingSessionRepository;
    private final DailyExerciseGoalRepository dailyExerciseGoalRepository;
    private final MedicationTaskRepository medicationTaskRepository;
    private final MedicineRepository medicineRepository;
    private final AppointmentRepository appointmentRepository;
    private final ReadingActivityRepository readingActivityRepository;
    private final CrosswordActivityRepository crosswordActivityRepository;
    private final MovieActivityRepository movieActivityRepository;

    @Autowired
    public DailyDataAggregatorManual(UserRepository userRepository, WellnessRepository wellnessRepository,
                                   NutritionalEntryRepository nutritionalEntryRepository,
                                   PhysicalActivityRepository physicalActivityRepository,
                                   WalkingSessionRepository walkingSessionRepository,
                                   DailyExerciseGoalRepository dailyExerciseGoalRepository,
                                   MedicationTaskRepository medicationTaskRepository,
                                   MedicineRepository medicineRepository,
                                   AppointmentRepository appointmentRepository,
                                   ReadingActivityRepository readingActivityRepository,
                                   CrosswordActivityRepository crosswordActivityRepository,
                                   MovieActivityRepository movieActivityRepository) {
        this.userRepository = userRepository;
        this.wellnessRepository = wellnessRepository;
        this.nutritionalEntryRepository = nutritionalEntryRepository;
        this.physicalActivityRepository = physicalActivityRepository;
        this.walkingSessionRepository = walkingSessionRepository;
        this.dailyExerciseGoalRepository = dailyExerciseGoalRepository;
        this.medicationTaskRepository = medicationTaskRepository;
        this.medicineRepository = medicineRepository;
        this.appointmentRepository = appointmentRepository;
        this.readingActivityRepository = readingActivityRepository;
        this.crosswordActivityRepository = crosswordActivityRepository;
        this.movieActivityRepository = movieActivityRepository;
    }

    public DailyDataBundleManual aggregateDailyData(String userId, LocalDate date) {
        User user = userRepository.findById(Long.valueOf(userId))
            .orElseThrow(() -> new RuntimeException("User not found"));

        return DailyDataBundleManual.builder()
            .user(user)
            .wellness(findWellnessByUserAndDate(user, date))
            .nutritionalEntries(findNutritionalEntriesByUserAndDate(user, date))
            .physicalActivities(findPhysicalActivitiesByUserAndDate(user, date))
            .walkingSessions(findWalkingSessionsByUserAndDate(user, date))
            .exerciseGoals(findExerciseGoalsByUserAndDate(user, date))
            .medicationTasks(findMedicationTasksByUserAndDate(user, date))
            .medicines(findMedicinesByUser(user))
            .appointments(findAppointmentsByUserAndDate(user, date))
            .readingActivities(findReadingActivitiesByUserAndDate(user, date))
            .crosswordActivities(findCrosswordActivitiesByUserAndDate(user, date))
            .movieActivities(findMovieActivitiesByUserAndDate(user, date))
            .build();
    }

    private Wellness findWellnessByUserAndDate(User user, LocalDate date) {
        List<Wellness> wellnessList = wellnessRepository.findByUserAndEntryDate(user, date);
        return wellnessList.isEmpty() ? null : wellnessList.get(0);
    }

    private List<NutritionalEntry> findNutritionalEntriesByUserAndDate(User user, LocalDate date) {
        return nutritionalEntryRepository.findByUserAndDateEquals(user, date);
    }

    private List<PhysicalActivityEntity> findPhysicalActivitiesByUserAndDate(User user, LocalDate date) {
        return physicalActivityRepository.findByUserAndDateBetween(user, date, date);
    }

    private List<WalkingSession> findWalkingSessionsByUserAndDate(User user, LocalDate date) {
        return walkingSessionRepository.findByUserAndStartTimeBetweenOrderByStartTimeDesc(
            user,
            date.atStartOfDay(),
            date.atTime(23, 59, 59)
        );
    }

    private DailyExerciseGoal findExerciseGoalsByUserAndDate(User user, LocalDate date) {
        return dailyExerciseGoalRepository.findByUserAndDate(user, date).orElse(null);
    }

    private List<MedicationTask> findMedicationTasksByUserAndDate(User user, LocalDate date) {
        // This is a simplified implementation - in practice, you'd need to filter by date
        // For now, returning all medication tasks for the user's medicines
        return medicationTaskRepository.findAll().stream()
            .filter(task -> task.getMedicine().getUser().getId().equals(user.getId()))
            .toList();
    }

    private List<Medicine> findMedicinesByUser(User user) {
        return medicineRepository.findByUser(user);
    }

    private List<Appointment> findAppointmentsByUserAndDate(User user, LocalDate date) {
        return appointmentRepository.findByUserAndDateBetween(
            user,
            date.atStartOfDay(),
            date.atTime(23, 59, 59)
        );
    }

    private List<ReadingActivity> findReadingActivitiesByUserAndDate(User user, LocalDate date) {
        return readingActivityRepository.findByUserOrderByStartDateDesc(user).stream()
            .filter(activity -> activity.getStartDate().equals(date))
            .toList();
    }

    private List<CrosswordActivity> findCrosswordActivitiesByUserAndDate(User user, LocalDate date) {
        return crosswordActivityRepository.findByUserOrderByDateDesc(user).stream()
            .filter(activity -> activity.getDate().equals(date))
            .toList();
    }

    private List<MovieActivity> findMovieActivitiesByUserAndDate(User user, LocalDate date) {
        return movieActivityRepository.findByUserOrderByWatchDateDesc(user).stream()
            .filter(activity -> activity.getWatchDate().equals(date))
            .toList();
    }
}
