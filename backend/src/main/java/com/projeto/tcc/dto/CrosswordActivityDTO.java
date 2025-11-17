package com.projeto.tcc.dto;

import java.time.LocalDate;

import com.projeto.tcc.entities.CrosswordActivity;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

public record CrosswordActivityDTO(
    Long id,

    @NotNull(message = "O ID do usuário é obrigatório")
    Long userId,
    
    @NotBlank(message = "O nome do quebra-cabeça é obrigatório")
    String puzzleName,
    
    @NotBlank(message = "A dificuldade é obrigatória")
    @Pattern(regexp = "easy|medium|hard", message = "A dificuldade deve ser: easy, medium ou hard")
    String difficulty,
    
    @NotNull(message = "A data é obrigatória")
    LocalDate date,
    
    @NotNull(message = "O tempo gasto é obrigatório")
    @Min(value = 0, message = "O tempo gasto não pode ser negativo")
    Integer timeSpentMinutes,
    
    Boolean isCompleted,
    
    String notes
) {
    public CrosswordActivityDTO(CrosswordActivity entity) {
        this(
            entity.getId(),
            entity.getUser().getId(),
            entity.getPuzzleName(),
            entity.getDifficulty(),
            entity.getDate(),
            entity.getTimeSpentMinutes(),
            entity.getIsCompleted(),
            entity.getNotes()
        );
    }
}
