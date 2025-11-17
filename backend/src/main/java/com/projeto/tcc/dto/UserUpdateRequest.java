package com.projeto.tcc.dto;

import java.util.Map;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public class UserUpdateRequest {

    @NotBlank(message = "Name is required")
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;

    private String caregiverName;

    @Email(message = "Caregiver email should be valid")
    private String caregiverEmail;

    private Map<String, Object> preferences;

    public UserUpdateRequest() {}

    public UserUpdateRequest(
            String name,
            String email,
            String caregiverName,
            String caregiverEmail,
            Map<String, Object> preferences
    ) {
        this.name = name;
        this.email = email;
        this.caregiverName = caregiverName;
        this.caregiverEmail = caregiverEmail;
        this.preferences = preferences;
    }

    // Getters and Setters
    public String getName() { 
        return name; 
    }
    public void setName(String name) { 
        this.name = name; 
    }

    public String getEmail() { 
        return email; 
    }
    public void setEmail(String email) { 
        this.email = email; 
    }

    public String getCaregiverName() { 
        return caregiverName; 
    }
    public void setCaregiverName(String caregiverName) { 
        this.caregiverName = caregiverName; 
    }

    public String getCaregiverEmail() { 
        return caregiverEmail; 
    }
    public void setCaregiverEmail(String caregiverEmail) { 
        this.caregiverEmail = caregiverEmail; 
    }

    public Map<String, Object> getPreferences() { 
        return preferences; 
    }
    public void setPreferences(Map<String, Object> preferences) { 
        this.preferences = preferences; 
    }
}
