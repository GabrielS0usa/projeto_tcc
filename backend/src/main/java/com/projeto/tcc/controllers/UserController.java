package com.projeto.tcc.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.projeto.tcc.dto.ProgressDTO;
import com.projeto.tcc.dto.UserProfileDTO;
import com.projeto.tcc.services.UserService;

@RestController
@RequestMapping(value = "/user")
public class UserController {

    @Autowired
    private UserService userService; 

    @GetMapping("/profile")
    public ResponseEntity<UserProfileDTO> getUserProfile() {
        UserProfileDTO dto = userService.getUserProfile();
        return ResponseEntity.ok(dto); 
    }

    @GetMapping("/progress/today")
    public ResponseEntity<ProgressDTO> getTodayProgress() {
        ProgressDTO dto = userService.getTodayProgress();
        return ResponseEntity.ok(dto);
    }
}

