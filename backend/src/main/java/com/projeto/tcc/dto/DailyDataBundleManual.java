package com.projeto.tcc.dto;

import com.projeto.tcc.entities.*;
import java.util.List;

public class DailyDataBundleManual {
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

    public DailyDataBundleManual() {}

    public DailyDataBundleManual(User user, Wellness wellness, List<NutritionalEntry> nutritionalEntries,
                          List<PhysicalActivityEntity> physicalActivities, List<WalkingSession> walkingSessions,
                          DailyExerciseGoal exerciseGoals, List<MedicationTask> medicationTasks,
                          List<Medicine> medicines, List<Appointment> appointments,
                          List<ReadingActivity> readingActivities, List<CrosswordActivity> crosswordActivities,
                          List<MovieActivity> movieActivities) {
        this.user = user;
        this.wellness = wellness;
        this.nutritionalEntries = nutritionalEntries;
        this.physicalActivities = physicalActivities;
        this.walkingSessions = walkingSessions;
        this.exerciseGoals = exerciseGoals;
        this.medicationTasks = medicationTasks;
        this.medicines = medicines;
        this.appointments = appointments;
        this.readingActivities = readingActivities;
        this.crosswordActivities = crosswordActivities;
        this.movieActivities = movieActivities;
    }

    public static DailyDataBundleBuilder builder() {
        return new DailyDataBundleBuilder();
    }

    public static class DailyDataBundleBuilder {
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

        public DailyDataBundleBuilder user(User user) {
            this.user = user;
            return this;
        }

        public DailyDataBundleBuilder wellness(Wellness wellness) {
            this.wellness = wellness;
            return this;
        }

        public DailyDataBundleBuilder nutritionalEntries(List<NutritionalEntry> nutritionalEntries) {
            this.nutritionalEntries = nutritionalEntries;
            return this;
        }

        public DailyDataBundleBuilder physicalActivities(List<PhysicalActivityEntity> physicalActivities) {
            this.physicalActivities = physicalActivities;
            return this;
        }

        public DailyDataBundleBuilder walkingSessions(List<WalkingSession> walkingSessions) {
            this.walkingSessions = walkingSessions;
            return this;
        }

        public DailyDataBundleBuilder exerciseGoals(DailyExerciseGoal exerciseGoals) {
            this.exerciseGoals = exerciseGoals;
            return this;
        }

        public DailyDataBundleBuilder medicationTasks(List<MedicationTask> medicationTasks) {
            this.medicationTasks = medicationTasks;
            return this;
        }

        public DailyDataBundleBuilder medicines(List<Medicine> medicines) {
            this.medicines = medicines;
            return this;
        }

        public DailyDataBundleBuilder appointments(List<Appointment> appointments) {
            this.appointments = appointments;
            return this;
        }

        public DailyDataBundleBuilder readingActivities(List<ReadingActivity> readingActivities) {
            this.readingActivities = readingActivities;
            return this;
        }

        public DailyDataBundleBuilder crosswordActivities(List<CrosswordActivity> crosswordActivities) {
            this.crosswordActivities = crosswordActivities;
            return this;
        }

        public DailyDataBundleBuilder movieActivities(List<MovieActivity> movieActivities) {
            this.movieActivities = movieActivities;
            return this;
        }

        public DailyDataBundleManual build() {
            return new DailyDataBundleManual(user, wellness, nutritionalEntries, physicalActivities,
                                     walkingSessions, exerciseGoals, medicationTasks, medicines,
                                     appointments, readingActivities, crosswordActivities, movieActivities);
        }
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
}
