package com.projeto.tcc.entities;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.Objects;

@Entity
@Table(name = "tb_daily_exercise_goal")
public class DailyExerciseGoal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private LocalDate date;

    private Integer targetSteps;

    private Integer targetMinutes;

    private Integer targetCalories;

    private Integer currentSteps = 0;

    private Integer currentMinutes = 0;

    private Integer currentCalories = 0;

    public DailyExerciseGoal() {
    }

    public DailyExerciseGoal(Long id, User user, LocalDate date, Integer targetSteps,
                            Integer targetMinutes, Integer targetCalories, Integer currentSteps,
                            Integer currentMinutes, Integer currentCalories) {
        this.id = id;
        this.user = user;
        this.date = date;
        this.targetSteps = targetSteps;
        this.targetMinutes = targetMinutes;
        this.targetCalories = targetCalories;
        this.currentSteps = currentSteps;
        this.currentMinutes = currentMinutes;
        this.currentCalories = currentCalories;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public Integer getTargetSteps() {
        return targetSteps;
    }

    public void setTargetSteps(Integer targetSteps) {
        this.targetSteps = targetSteps;
    }

    public Integer getTargetMinutes() {
        return targetMinutes;
    }

    public void setTargetMinutes(Integer targetMinutes) {
        this.targetMinutes = targetMinutes;
    }

    public Integer getTargetCalories() {
        return targetCalories;
    }

    public void setTargetCalories(Integer targetCalories) {
        this.targetCalories = targetCalories;
    }

    public Integer getCurrentSteps() {
        return currentSteps;
    }

    public void setCurrentSteps(Integer currentSteps) {
        this.currentSteps = currentSteps;
    }

    public Integer getCurrentMinutes() {
        return currentMinutes;
    }

    public void setCurrentMinutes(Integer currentMinutes) {
        this.currentMinutes = currentMinutes;
    }

    public Integer getCurrentCalories() {
        return currentCalories;
    }

    public void setCurrentCalories(Integer currentCalories) {
        this.currentCalories = currentCalories;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        DailyExerciseGoal that = (DailyExerciseGoal) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
