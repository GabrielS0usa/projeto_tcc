package com.projeto.tcc.entities;

import jakarta.persistence.*;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Map;
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

    @Column(name = "metric_value", nullable = false)
    private Double value;

    @Column(nullable = false)
    private String unit; // Unit of measurement

    // Enhanced fields for statistics
    private Double secondaryValue;
    private Integer qualityScore;
    private Duration duration;

    @ElementCollection
    @CollectionTable(name = "activity_metadata", joinColumns = @JoinColumn(name = "activity_id"))
    @MapKeyColumn(name = "meta_key") 
    @Column(name = "meta_value")       
    private Map<String, String> metadata;

    // Legacy fields for backward compatibility
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

    public Activity(Long id, User user, ActivityType type, LocalDateTime timestamp, Double value, String unit,
                    Double secondaryValue, Integer qualityScore, Duration duration, Map<String, String> metadata,
                    String description, MedicationTask medicationTaskOrigin, String details) {
        this.id = id;
        this.user = user;
        this.type = type;
        this.timestamp = timestamp;
        this.value = value;
        this.unit = unit;
        this.secondaryValue = secondaryValue;
        this.qualityScore = qualityScore;
        this.duration = duration;
        this.metadata = metadata;
        this.description = description;
        this.medicationTaskOrigin = medicationTaskOrigin;
        this.details = details;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public ActivityType getType() { return type; }
    public void setType(ActivityType type) { this.type = type; }
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
    public Double getValue() { return value; }
    public void setValue(Double value) { this.value = value; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public Double getSecondaryValue() { return secondaryValue; }
    public void setSecondaryValue(Double secondaryValue) { this.secondaryValue = secondaryValue; }
    public Integer getQualityScore() { return qualityScore; }
    public void setQualityScore(Integer qualityScore) { this.qualityScore = qualityScore; }
    public Duration getDuration() { return duration; }
    public void setDuration(Duration duration) { this.duration = duration; }
    public Map<String, String> getMetadata() { return metadata; }
    public void setMetadata(Map<String, String> metadata) { this.metadata = metadata; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public MedicationTask getMedicationTaskOrigin() { return medicationTaskOrigin; }
    public void setMedicationTaskOrigin(MedicationTask medicationTaskOrigin) { this.medicationTaskOrigin = medicationTaskOrigin; }
    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    // Statistical calculation methods
    public Double calculateEfficiency() {
        if (value == null || duration == null || duration.isZero()) return 0.0;
        return value / duration.toMinutes();
    }

    public boolean isWithinTargetRange() {
        if (qualityScore == null) return false;
        return qualityScore >= 70; // Example threshold
    }

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


