package com.projeto.tcc.dto;

import jakarta.validation.constraints.Email;

public record RegisterDTO(String name, @Email String email, String phone, String birthDate, String password, @Email(message = "Email do cuidador inválido") String caregiverEmail) {
}
