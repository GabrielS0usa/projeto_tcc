package com.projeto.tcc.dto;

import java.time.LocalDate;

import jakarta.validation.constraints.NotNull;

public class DailyReportRequestDTO {

    @NotNull
    private String userId;

    @NotNull
    private LocalDate date;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }
}
