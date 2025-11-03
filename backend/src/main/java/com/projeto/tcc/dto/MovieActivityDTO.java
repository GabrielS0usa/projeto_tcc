package com.projeto.tcc.dto;

import java.time.LocalDate;

import com.projeto.tcc.entities.MovieActivity;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record MovieActivityDTO(
    Long id,
    
    @NotBlank(message = "O título do filme é obrigatório")
    String movieTitle,
    
    String genre,
    
    @NotNull(message = "A avaliação é obrigatória")
    @Min(value = 1, message = "A avaliação mínima é 1")
    @Max(value = 5, message = "A avaliação máxima é 5")
    Integer rating,
    
    @NotNull(message = "A data de visualização é obrigatória")
    LocalDate watchDate,
    
    String review,
    
    Boolean isWatched
) {
    public MovieActivityDTO(MovieActivity entity) {
        this(
            entity.getId(),
            entity.getMovieTitle(),
            entity.getGenre(),
            entity.getRating(),
            entity.getWatchDate(),
            entity.getReview(),
            entity.getIsWatched()
        );
    }
}
