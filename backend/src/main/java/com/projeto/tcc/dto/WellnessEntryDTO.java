package com.projeto.tcc.dto;

import com.projeto.tcc.entities.DayPeriod;
import com.projeto.tcc.entities.Mood;

import jakarta.validation.constraints.NotNull;

public record WellnessEntryDTO(
	    @NotNull Mood mood,
	    @NotNull DayPeriod period,
	    String note
	) {}
