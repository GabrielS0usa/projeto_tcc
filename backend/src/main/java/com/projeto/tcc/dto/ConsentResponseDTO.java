package com.projeto.tcc.dto;

import java.time.LocalDateTime;

public record ConsentResponseDTO(
    boolean dataSharing,
    boolean analytics,
    boolean notifications,
    LocalDateTime lastUpdated,
    boolean active,
    String caregiverEmail,
    String caregiverName
) {
    public ConsentResponseDTO() {
        this(false, false, false, null, false, null, null);
    }

    public ConsentResponseDTO(com.projeto.tcc.entities.Consent consent) {
        this(consent.isDataSharing(), consent.isAnalytics(), consent.isNotifications(),
             consent.getLastUpdated(), consent.isActive(), consent.getCaregiverEmail(), consent.getCaregiverName());
    }
}
