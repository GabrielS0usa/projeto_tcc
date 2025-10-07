package com.projeto.tcc.entities;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Objects;

import org.springframework.security.core.GrantedAuthority;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "tb_medicine")
public class medicine {
	
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;
	private String name;
	private String dose;
	private LocalTime hour_medicine;
	private LocalDate date_medicine;
	
	public medicine() {
	}

	public medicine(Long id, String name, String dose, LocalTime hour, LocalDate date) {
		this.id = id;
		this.name = name;
		this.dose = dose;
		this.hour_medicine = hour;
		this.date_medicine = date;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDose() {
		return dose;
	}

	public void setDose(String dose) {
		this.dose = dose;
	}

	public LocalTime getHour() {
		return hour_medicine;
	}

	public void setHour(LocalTime hour) {
		this.hour_medicine = hour;
	}

	public LocalDate getDate() {
		return date_medicine;
	}

	public void setDate(LocalDate date) {
		this.date_medicine = date;
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
		medicine other = (medicine) obj;
		return Objects.equals(id, other.id);
	}
}
