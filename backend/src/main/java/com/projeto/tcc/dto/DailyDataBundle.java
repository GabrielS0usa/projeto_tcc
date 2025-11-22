package com.projeto.tcc.dto;

import java.util.List;

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

public class DailyDataBundle {
    private User user;
    private Wellness wellness;
    private List<NutritionalEntry> nutritionalEntries;
    private List<PhysicalActivityEntity> physicalActivities;
    private List<WalkingSession> walkingSessions;
    private DailyExerciseGoal exerciseGoals;
    private List<MedicationTask> medicationTasks;
    private List<Medicine> medicines;
    private List<Appointment> appointments;
    private List<ReadingActivity> readingActivities;
    private List<CrosswordActivity> crosswordActivities;
    private List<MovieActivity> movieActivities;

    // Construtor privado para forçar o uso do Builder
    private DailyDataBundle() {
    }

    // Getters
    public User getUser() { return user; }
    public Wellness getWellness() { return wellness; }
    public List<NutritionalEntry> getNutritionalEntries() { return nutritionalEntries; }
    public List<PhysicalActivityEntity> getPhysicalActivities() { return physicalActivities; }
    public List<WalkingSession> getWalkingSessions() { return walkingSessions; }
    public DailyExerciseGoal getExerciseGoals() { return exerciseGoals; }
    public List<MedicationTask> getMedicationTasks() { return medicationTasks; }
    public List<Medicine> getMedicines() { return medicines; }
    public List<Appointment> getAppointments() { return appointments; }
    public List<ReadingActivity> getReadingActivities() { return readingActivities; }
    public List<CrosswordActivity> getCrosswordActivities() { return crosswordActivities; }
    public List<MovieActivity> getMovieActivities() { return movieActivities; }

    // Builder manual
    public static class Builder {
        private final DailyDataBundle instance = new DailyDataBundle();

        public Builder user(User user) { instance.user = user; return this; }
        public Builder wellness(Wellness wellness) { instance.wellness = wellness; return this; }
        public Builder nutritionalEntries(List<NutritionalEntry> entries) { instance.nutritionalEntries = entries; return this; }
        public Builder physicalActivities(List<PhysicalActivityEntity> activities) { instance.physicalActivities = activities; return this; }
        public Builder walkingSessions(List<WalkingSession> sessions) { instance.walkingSessions = sessions; return this; }
        public Builder exerciseGoals(DailyExerciseGoal goals) { instance.exerciseGoals = goals; return this; }
        public Builder medicationTasks(List<MedicationTask> tasks) { instance.medicationTasks = tasks; return this; }
        public Builder medicines(List<Medicine> medicines) { instance.medicines = medicines; return this; }
        public Builder appointments(List<Appointment> appointments) { instance.appointments = appointments; return this; }
        public Builder readingActivities(List<ReadingActivity> activities) { instance.readingActivities = activities; return this; }
        public Builder crosswordActivities(List<CrosswordActivity> activities) { instance.crosswordActivities = activities; return this; }
        public Builder movieActivities(List<MovieActivity> activities) { instance.movieActivities = activities; return this; }

        public DailyDataBundle build() { return instance; }
    }

    public static Builder builder() { return new Builder(); }
}
