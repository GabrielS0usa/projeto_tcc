package com.projeto.tcc.controllers;

import java.net.URI;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import com.projeto.tcc.dto.AuthenticationDTO;
import com.projeto.tcc.dto.LoginResponseDTO;
import com.projeto.tcc.dto.RegisterDTO;
import com.projeto.tcc.services.AuthenticationService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("auth")
public class AuthenticationController {
	
	@Autowired
	AuthenticationService service;
	
	@PostMapping("/login")
	public ResponseEntity<LoginResponseDTO> login(@RequestBody @Valid AuthenticationDTO data) {
		LoginResponseDTO dto = service.login(data);
		
		var token = dto.token();
		var id = dto.userId();
		
		return ResponseEntity.ok(dto);
	}
	
	@PostMapping("/register")
	public ResponseEntity register(@RequestBody @Valid RegisterDTO data) {	
		var newUser = service.register(data);
		URI uri = ServletUriComponentsBuilder.fromCurrentRequest().path("/{id}").buildAndExpand(newUser.getId()).toUri();
		return ResponseEntity.created(uri).body(newUser);
	}
}
