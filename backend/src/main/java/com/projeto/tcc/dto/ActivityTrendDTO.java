package com.projeto.tcc.dto;

import java.time.LocalDate;

public class ActivityTrendDTO {
    private LocalDate date;
    private Double averageValue;
    private Long count;

    public ActivityTrendDTO(java.sql.Date date, Double averageValue, Long count) {
        this.date = date.toLocalDate(); 
        this.averageValue = averageValue;
        this.count = count;
    }

    // Getters and Setters
    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }
    public Double getAverageValue() { return averageValue; }
    public void setAverageValue(Double averageValue) { this.averageValue = averageValue; }
    public Long getCount() { return count; }
    public void setCount(Long count) { this.count = count; }
}
