package com.projeto.tcc.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.projeto.tcc.entities.Role;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.projections.UserDetailsProjection;
import com.projeto.tcc.repositories.UserRepository;

@Service
public class AuthorizationService implements UserDetailsService{
	
	@Autowired
	private UserRepository repository;

	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		
		List<UserDetailsProjection> result = repository.searchUserAndRolesByEmail(username);
		if (result.isEmpty()) {
			throw new UsernameNotFoundException("User not found");
		}
		
		User user = new User();
		user.setEmail(username);
		user.setPassword(result.get(0).getPassword());
		for (UserDetailsProjection obj : result) {
			user.addRole(new Role(obj.getRoleId(), obj.getAuthority()));
		}
		
		return user;
	}
	
}
