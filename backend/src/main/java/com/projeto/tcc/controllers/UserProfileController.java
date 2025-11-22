package com.projeto.tcc.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.projeto.tcc.dto.UserProfileDTO;
import com.projeto.tcc.dto.UserUpdateRequest;
import com.projeto.tcc.services.UserProfileService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/users/{userId}/profile")
@CrossOrigin(origins = "*")
public class UserProfileController {

    @Autowired
    private UserProfileService userProfileService;

    @GetMapping
    public ResponseEntity<UserProfileDTO> getUserProfile(@PathVariable Long userId) {
        UserProfileDTO profile = userProfileService.getUserProfile(userId);
        return ResponseEntity.ok(profile);
    }

    @PutMapping
    public ResponseEntity<UserProfileDTO> updateUserProfile(@PathVariable Long userId, @RequestBody @Valid  UserUpdateRequest request) {
        UserProfileDTO updatedProfile = userProfileService.updateUserProfile(userId, request);
        return ResponseEntity.ok(updatedProfile);
    }
}
