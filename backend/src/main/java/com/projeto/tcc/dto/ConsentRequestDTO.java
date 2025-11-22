package com.projeto.tcc.dto;

public record ConsentRequestDTO(
    Boolean dataSharing,

    Boolean analytics,

    Boolean notifications,

    Boolean active,

    String caregiverEmail
) {}
