package com.projeto.tcc.dto;

import java.time.LocalDate;

import com.projeto.tcc.entities.ReadingActivity;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record ReadingActivityDTO(
    Long id,
    
    @NotBlank(message = "O título do livro é obrigatório")
    String bookTitle,
    
    String author,
    
    @NotNull(message = "O total de páginas é obrigatório")
    @Min(value = 1, message = "O total de páginas deve ser maior que zero")
    Integer totalPages,
    
    @NotNull(message = "A página atual é obrigatória")
    @Min(value = 0, message = "A página atual não pode ser negativa")
    Integer currentPage,
    
    String notes,
    
    @NotNull(message = "A data de início é obrigatória")
    LocalDate startDate,
    
    LocalDate completionDate,
    
    Boolean isCompleted
) {
    public ReadingActivityDTO(ReadingActivity entity) {
        this(
            entity.getId(),
            entity.getBookTitle(),
            entity.getAuthor(),
            entity.getTotalPages(),
            entity.getCurrentPage(),
            entity.getNotes(),
            entity.getStartDate(),
            entity.getCompletionDate(),
            entity.getIsCompleted()
        );
    }
    
    public Double getProgressPercentage() {
        if (totalPages == null || totalPages == 0) return 0.0;
        return Math.min((currentPage.doubleValue() / totalPages.doubleValue()) * 100, 100.0);
    }
}
