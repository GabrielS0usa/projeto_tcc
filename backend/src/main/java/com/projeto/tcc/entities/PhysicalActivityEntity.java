package com.projeto.tcc.entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "tb_physical_activity")
public class PhysicalActivityEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String activityType; // walking, running, cycling, swimming, yoga, other

    @Column(nullable = false)
    private String activityName;

    @Column(nullable = false)
    private LocalDateTime date;

    @Column(nullable = false)
    private Integer durationMinutes;

    @Column(nullable = false)
    private Integer caloriesBurned;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(nullable = false)
    private Integer intensityLevel; // 1-5 scale

    public PhysicalActivityEntity() {
    }

    public PhysicalActivityEntity(Long id, User user, String activityType, String activityName,
                                 LocalDateTime date, Integer durationMinutes, Integer caloriesBurned,
                                 String notes, Integer intensityLevel) {
        this.id = id;
        this.user = user;
        this.activityType = activityType;
        this.activityName = activityName;
        this.date = date;
        this.durationMinutes = durationMinutes;
        this.caloriesBurned = caloriesBurned;
        this.notes = notes;
        this.intensityLevel = intensityLevel;
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

    public String getActivityType() {
        return activityType;
    }

    public void setActivityType(String activityType) {
        this.activityType = activityType;
    }

    public String getActivityName() {
        return activityName;
    }

    public void setActivityName(String activityName) {
        this.activityName = activityName;
    }

    public LocalDateTime getDate() {
        return date;
    }

    public void setDate(LocalDateTime date) {
        this.date = date;
    }

    public Integer getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(Integer durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    public Integer getCaloriesBurned() {
        return caloriesBurned;
    }

    public void setCaloriesBurned(Integer caloriesBurned) {
        this.caloriesBurned = caloriesBurned;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Integer getIntensityLevel() {
        return intensityLevel;
    }

    public void setIntensityLevel(Integer intensityLevel) {
        this.intensityLevel = intensityLevel;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        PhysicalActivityEntity that = (PhysicalActivityEntity) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
