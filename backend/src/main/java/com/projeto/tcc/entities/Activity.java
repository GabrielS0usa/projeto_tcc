package com.projeto.tcc.entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "tb_activity") 
public class Activity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ActivityType type; 

    @Column(nullable = false)
    private LocalDateTime timestamp; 

    @Column(nullable = false)
    private String description; 

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "medication_task_id", referencedColumnName = "id", nullable = true)
    private MedicationTask medicationTaskOrigin; 

    @Column(columnDefinition = "TEXT")
    private String details; 

    public Activity() {
        this.timestamp = LocalDateTime.now(); 
    }

    public Activity(Long id, User user, ActivityType type, LocalDateTime timestamp, String description, MedicationTask medicationTaskOrigin, String details) {
        this.id = id;
        this.user = user;
        this.type = type;
        this.timestamp = timestamp;
        this.description = description;
        this.medicationTaskOrigin = medicationTaskOrigin;
        this.details = details;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public ActivityType getType() { return type; }
    public void setType(ActivityType type) { this.type = type; }
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public MedicationTask getMedicationTaskOrigin() { return medicationTaskOrigin; }
    public void setMedicationTaskOrigin(MedicationTask medicationTaskOrigin) { this.medicationTaskOrigin = medicationTaskOrigin; }
    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Activity activity = (Activity) o;
        return Objects.equals(id, activity.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}

enum ActivityType {
    MEDICATION_TAKEN, 
    WELLNESS_LOGGED,
    EXERCISE_DONE 
}