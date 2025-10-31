package com.projeto.tcc.dto;

public record ConsentResponseDTO(
    boolean active,
    String caregiverEmail, 
    String caregiverName 
) {}
