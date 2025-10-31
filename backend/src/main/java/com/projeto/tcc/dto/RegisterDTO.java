package com.projeto.tcc.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank; 

public record RegisterDTO(
        
        @NotBlank(message = "Nome do usuário é obrigatório") String name,
        @NotBlank(message = "Email do usuário é obrigatório") @Email String email,
        String phone, 
        @NotBlank(message = "Data de nascimento é obrigatória") String birthDate,
        @NotBlank(message = "Senha é obrigatória") String password,

        @Email(message = "Email do cuidador inválido") String caregiverEmail, 
        String caregiverName 
) {}
