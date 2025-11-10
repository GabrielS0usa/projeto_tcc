package com.projeto.tcc.entities;

import jakarta.persistence.*;
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
    @JoinColumn(name = "caregiver_id", referencedColumnName = "id", nullable = false)
    private Caregiver caregiver; 

    @Column(nullable = false)
    private boolean active;

    public Consent() {
        this.active = false;
    }

    public Consent(Long id, User user, Caregiver caregiver, boolean active) {
        this.id = id;
        this.user = user;
        this.caregiver = caregiver;
        this.active = active;
    }

    // Getters e Setters
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

    // equals e hashCode baseados no ID
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