package com.projeto.tcc.dto;

import java.util.ArrayList;
import java.util.List;

import org.springframework.security.core.GrantedAuthority;

import com.projeto.tcc.entities.User;

public class UserMinDTO {
	
	private Long id;
	private String name;
    private List<String> roles = new ArrayList<>();
    
	public UserMinDTO(User entity) {
		this.id = entity.getId();
		this.name = entity.getName();
		for (GrantedAuthority role: entity.getAuthorities()) {
			roles.add(role.getAuthority());
		}
	}

	public Long getId() {
		return id;
	}

	public String getName() {
		return name;
	}

	public List<String> getRoles() {
		return roles;
	}
}