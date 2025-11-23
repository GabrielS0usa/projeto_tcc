package com.projeto.tcc.entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "tb_consent")
public class Consent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", referencedColumnName = "id", nullable = false, unique = true)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "caregiver_id", referencedColumnName = "id", nullable = true)
    private Caregiver caregiver;

    @Column(nullable = false)
    private boolean active;

    private boolean dataSharing;
    private boolean analytics;
    private boolean notifications;
    private LocalDateTime lastUpdated;

    public Consent() {
        this.active = false;
        this.dataSharing = false;
        this.analytics = false;
        this.notifications = false;
    }

    public Consent(Long id, User user, Caregiver caregiver, boolean active, boolean dataSharing, boolean analytics, boolean notifications, LocalDateTime lastUpdated) {
        this.id = id;
        this.user = user;
        this.caregiver = caregiver;
        this.active = active;
        this.dataSharing = dataSharing;
        this.analytics = analytics;
        this.notifications = notifications;
        this.lastUpdated = lastUpdated;
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

    public Caregiver getCaregiver() {
        return caregiver;
    }

    public void setCaregiver(Caregiver caregiver) {
        this.caregiver = caregiver;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public boolean isDataSharing() {
        return dataSharing;
    }

    public void setDataSharing(boolean dataSharing) {
        this.dataSharing = dataSharing;
    }

    public boolean isAnalytics() {
        return analytics;
    }

    public void setAnalytics(boolean analytics) {
        this.analytics = analytics;
    }

    public boolean isNotifications() {
        return notifications;
    }

    public void setNotifications(boolean notifications) {
        this.notifications = notifications;
    }

    public LocalDateTime getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(LocalDateTime lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public String getCaregiverEmail() {
        return caregiver != null ? caregiver.getEmail() : null;
    }

    public String getCaregiverName() {
        return caregiver != null ? caregiver.getName() : null;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Consent consent = (Consent) o;
        return Objects.equals(id, consent.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
