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
import com.projeto.tcc.entities.Caregiver;
import com.projeto.tcc.entities.Consent;
import com.projeto.tcc.entities.Role;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.repositories.CaregiverRepository;
import com.projeto.tcc.repositories.ConsentRepository;
import com.projeto.tcc.repositories.RoleRepository;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.services.exceptions.DatabaseException;
import com.projeto.tcc.services.exceptions.ResourceNotFoundException;

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

	@Autowired
	private CaregiverRepository caregiverRepository;
	
	@Autowired
    private ConsentRepository consentRepository;

	DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");

	public LoginResponseDTO login(AuthenticationDTO data) {
		var usernamePassword = new UsernamePasswordAuthenticationToken(data.email(), data.password());
		var auth = this.authenticationManager.authenticate(usernamePassword);
		
		var user = (User) auth.getPrincipal();
		var token = tokenService.generateToken((User) auth.getPrincipal());
		Long userId = user.getId();
		
		return new LoginResponseDTO(token, userId);
	}

	public UserMinDTO register(RegisterDTO data) {
		if (repository.findByEmail(data.email()).isPresent()) {
			throw new DatabaseException("E-mail já cadastrado!");
		}

		String encryptedPassword = new BCryptPasswordEncoder().encode(data.password());
		User newUser = new User();

		copyDtoToEntity(data, newUser, encryptedPassword);

		repository.save(newUser);

		if (data.caregiverEmail() != null && !data.caregiverEmail().isBlank()) {

			Caregiver caregiver = caregiverRepository.findByEmail(data.caregiverEmail()).orElseGet(() -> {
				Caregiver newCaregiver = new Caregiver();
				newCaregiver.setEmail(data.caregiverEmail());
				newCaregiver.setName(data.caregiverName()); 
				return caregiverRepository.save(newCaregiver);
			});

			
			Consent newConsent = new Consent();
			newConsent.setUser(newUser);
			newConsent.setCaregiver(caregiver); 
			newConsent.setActive(false); 

			consentRepository.save(newConsent);
		}

		return new UserMinDTO(newUser);
	}

	private void copyDtoToEntity(RegisterDTO dto, User entity, String password) {
        entity.setName(dto.name());
        entity.setEmail(dto.email());
        entity.setPhone(dto.phone());
        try {
            entity.setBirthDate(LocalDate.parse(dto.birthDate(), formatter));
        } catch (Exception e) {
            throw new IllegalArgumentException("Formato inválido para data de nascimento. Use dd-MM-yyyy.");
        }
        entity.setPassword(password);
        Role role = roleRepository.findById(1L) 
                .orElseThrow(() -> new ResourceNotFoundException("Role padrão 'ROLE_USER' não encontrada no banco."));
        entity.getRoles().clear(); 
        entity.addRole(role);
    }
}
