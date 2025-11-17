package com.projeto.tcc;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class ProjetoTCC {

	public static void main(String[] args) {
		SpringApplication.run(ProjetoTCC.class, args);
	}

}
