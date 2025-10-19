package com.projeto.tcc.services;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.projeto.tcc.config.security.TokenService;
import com.projeto.tcc.dto.AuthenticationDTO;
import com.projeto.tcc.dto.LoginResponseDTO;
import com.projeto.tcc.dto.RegisterDTO;
import com.projeto.tcc.dto.UserMinDTO;
import com.projeto.tcc.entities.Role;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.repositories.RoleRepository;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.services.exceptions.DatabaseException;

@Service
public class AuthenticationService {
	
	@Autowired
	private AuthenticationManager authenticationManager;
	
	@Autowired
	private RoleRepository roleRepository;
	
	@Autowired
	private UserRepository repository;
	
	@Autowired
	private TokenService tokenService;
	
	DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");
	
	public LoginResponseDTO login (AuthenticationDTO data) {
		var usernamePassword = new UsernamePasswordAuthenticationToken(data.email(), data.password());
		var auth = this.authenticationManager.authenticate(usernamePassword);
		
		var token = tokenService.generateToken((User)auth.getPrincipal());
		
		return new LoginResponseDTO(token);
	}
	
	
	public UserMinDTO register(RegisterDTO data) {
		if (repository.findByEmail(data.email()).isPresent()) {
			throw new DatabaseException("E-mail já cadastrado!");
		}
		
		String encryptedPassword = new BCryptPasswordEncoder().encode(data.password());
		User newUser = new User();
		copyDtoToEntity(data, newUser, encryptedPassword);
		
		repository.save(newUser);
		
		return new UserMinDTO(newUser);
	}
	
	private void copyDtoToEntity(RegisterDTO dto, User entity, String password) {
		entity.setName(dto.name());
		entity.setEmail(dto.email());
		entity.setPhone(dto.phone());
		entity.setBirthDate(LocalDate.parse(dto.birthDate(), formatter));
		entity.setPassword(password);
		entity.setCaregiverEmail(dto.caregiverEmail());
		Role role = roleRepository.findById(1L)
                .orElseThrow(() -> new RuntimeException("Role padrão não encontrada"));
        entity.addRole(role);
	}
}
