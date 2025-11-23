package com.projeto.tcc.entities;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.Objects;

@Entity
@Table(name = "tb_wellness_entry")
public class Wellness {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Mood mood;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DayPeriod period; 

    @Column(columnDefinition = "TEXT")
    private String note;

    private LocalDate entryDate;

	public Wellness(Long id, User user, Mood mood, DayPeriod period, String note, LocalDate entryDate) {
		super();
		this.id = id;
		this.user = user;
		this.mood = mood;
		this.period = period;
		this.note = note;
		this.entryDate = entryDate;
	}

	public Wellness() {
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

	public Mood getMood() {
		return mood;
	}

	public void setMood(Mood mood) {
		this.mood = mood;
	}

	public DayPeriod getPeriod() {
		return period;
	}

	public void setPeriod(DayPeriod period) {
		this.period = period;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public LocalDate getEntryDate() {
		return entryDate;
	}

	public void setEntryDate(LocalDate entryDate) {
		this.entryDate = entryDate;
	}

	@Override
	public int hashCode() {
		return Objects.hash(id);
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Wellness other = (Wellness) obj;
		return Objects.equals(id, other.id);
	} 
    
}