package com.projeto.tcc.entities;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.Objects;

@Entity
@Table(name = "tb_crossword_activity")
public class CrosswordActivity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String puzzleName;

    @Column(nullable = false)
    private String difficulty; // 'easy', 'medium', 'hard'

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private Integer timeSpentMinutes;

    @Column(nullable = false)
    private Boolean isCompleted = false;

    @Column(columnDefinition = "TEXT")
    private String notes;

    public CrosswordActivity() {
    }

    public CrosswordActivity(Long id, User user, String puzzleName, String difficulty, 
                            LocalDate date, Integer timeSpentMinutes, Boolean isCompleted, String notes) {
        this.id = id;
        this.user = user;
        this.puzzleName = puzzleName;
        this.difficulty = difficulty;
        this.date = date;
        this.timeSpentMinutes = timeSpentMinutes;
        this.isCompleted = isCompleted;
        this.notes = notes;
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

    public String getPuzzleName() {
        return puzzleName;
    }

    public void setPuzzleName(String puzzleName) {
        this.puzzleName = puzzleName;
    }

    public String getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public Integer getTimeSpentMinutes() {
        return timeSpentMinutes;
    }

    public void setTimeSpentMinutes(Integer timeSpentMinutes) {
        this.timeSpentMinutes = timeSpentMinutes;
    }

    public Boolean getIsCompleted() {
        return isCompleted;
    }

    public void setIsCompleted(Boolean isCompleted) {
        this.isCompleted = isCompleted;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        CrosswordActivity that = (CrosswordActivity) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
