package com.projeto.tcc.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;

public record ConsentRequestDTO(
    @NotNull(message = "O status ativo é obrigatório")
    Boolean active,

    @Email(message = "Email do cuidador inválido")
    String caregiverEmail
) {}
