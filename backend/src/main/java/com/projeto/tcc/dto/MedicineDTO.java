package com.projeto.tcc.dto;

import java.time.LocalDate;
import java.time.LocalTime;

import com.projeto.tcc.entities.Medicine;

public class MedicineDTO {

    private Long id;
    private String name;
    private String dose;
    private LocalTime startTime;
    private Integer intervalHours;
    private Integer durationDays;
    private LocalDate startDate;

    public MedicineDTO() {}

    public MedicineDTO(Medicine entity) {
        this.id = entity.getId();
        this.name = entity.getName();
        this.dose = entity.getDose();
        this.startTime = entity.getStartTime();
        this.intervalHours = entity.getIntervalHours();
        this.durationDays = entity.getDurationDays();
        this.startDate = entity.getStartDate();
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

    public LocalTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }

    public Integer getIntervalHours() {
        return intervalHours;
    }

    public void setIntervalHours(Integer intervalHours) {
        this.intervalHours = intervalHours;
    }

    public Integer getDurationDays() {
        return durationDays;
    }

    public void setDurationDays(Integer durationDays) {
        this.durationDays = durationDays;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }
}