package com.projeto.tcc.dto;

import java.time.LocalDate;

public record UserProfileDTO(
    String name,
    String email,
    String phone,
    LocalDate birthDate,
    String nameCaregiver,
    String emailCaregiver
) {}
