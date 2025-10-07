package com.projeto.tcc.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.projeto.tcc.repositories.UserRepository;

@Service
public class UserService{
	
	@Autowired
	UserRepository repository;
	
}
