package com.projeto.tcc.controllers.handlers;

import java.time.Instant;

import javax.naming.AuthenticationException;
import javax.security.auth.login.AccountExpiredException;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.CredentialsExpiredException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import com.projeto.tcc.dto.CustomError;
import com.projeto.tcc.dto.ValidationError;
import com.projeto.tcc.services.exceptions.DatabaseException;
import com.projeto.tcc.services.exceptions.ForbiddenException;
import com.projeto.tcc.services.exceptions.ResourceNotFoundException;

import jakarta.servlet.http.HttpServletRequest;

//@ControllerAdvice
public class ResourceExceptionHandler {

	@ExceptionHandler(ResourceNotFoundException.class)
	public ResponseEntity<CustomError> resourceNotFound(ResourceNotFoundException e, HttpServletRequest request) {
		HttpStatus status = HttpStatus.NOT_FOUND;
		CustomError err = new CustomError(Instant.now(), status.value(), e.getMessage(), request.getRequestURI());
		return ResponseEntity.status(status).body(err);
	}

	@ExceptionHandler(DatabaseException.class)
	public ResponseEntity<CustomError> databaseException(DatabaseException e, HttpServletRequest request) {
		HttpStatus status = HttpStatus.BAD_REQUEST;
		CustomError err = new CustomError(Instant.now(), status.value(), e.getMessage(), request.getRequestURI());
		return ResponseEntity.status(status).body(err);
	}

	@ExceptionHandler(MethodArgumentNotValidException.class)
	public ResponseEntity<CustomError> methodArgumentNotValid(MethodArgumentNotValidException e,
			HttpServletRequest request) {
		HttpStatus status = HttpStatus.UNPROCESSABLE_ENTITY;
		ValidationError err = new ValidationError(Instant.now(), status.value(), "Dados inválidos",
				request.getRequestURI());
		for (FieldError f : e.getBindingResult().getFieldErrors()) {
			err.addError(f.getField(), f.getDefaultMessage());
		}
		return ResponseEntity.status(status).body(err);
	}

	@ExceptionHandler(ForbiddenException.class)
	public ResponseEntity<CustomError> forbidden(ForbiddenException e, HttpServletRequest request) {
		HttpStatus status = HttpStatus.FORBIDDEN;
		CustomError err = new CustomError(Instant.now(), status.value(), e.getMessage(), request.getRequestURI());
		return ResponseEntity.status(status).body(err);
	}

	@ExceptionHandler(BadCredentialsException.class)
	public ResponseEntity<CustomError> badCredentials(BadCredentialsException e, HttpServletRequest request) {
		HttpStatus status = HttpStatus.UNAUTHORIZED;
		String friendlyMessage = "Credenciais inválidas. Por favor, verifique seu e-mail e senha.";
		CustomError err = new CustomError(Instant.now(), status.value(), friendlyMessage, request.getRequestURI());
		return ResponseEntity.status(status).body(err);
	}

	@ExceptionHandler(UsernameNotFoundException.class)
	public ResponseEntity<CustomError> handleUsernameNotFound(UsernameNotFoundException e, HttpServletRequest request) {
		String friendlyMessage = "Usuário não encontrado. Verifique o e-mail digitado.";
		return createErrorResponse(HttpStatus.UNAUTHORIZED, friendlyMessage, e.getMessage(), request.getRequestURI());
	}

	@ExceptionHandler(DisabledException.class)
	public ResponseEntity<CustomError> handleDisabledAccount(DisabledException e, HttpServletRequest request) {
		String friendlyMessage = "Esta conta de usuário foi desativada.";
		return createErrorResponse(HttpStatus.FORBIDDEN, friendlyMessage, e.getMessage(), request.getRequestURI());
	}

	@ExceptionHandler(LockedException.class)
	public ResponseEntity<CustomError> handleLockedAccount(LockedException e, HttpServletRequest request) {
		String friendlyMessage = "Esta conta está bloqueada. Entre em contato com o suporte.";
		return createErrorResponse(HttpStatus.FORBIDDEN, friendlyMessage, e.getMessage(), request.getRequestURI());
	}

	@ExceptionHandler(AccountExpiredException.class)
	public ResponseEntity<CustomError> handleExpiredAccount(AccountExpiredException e, HttpServletRequest request) {
		String friendlyMessage = "Sua conta expirou.";
		return createErrorResponse(HttpStatus.FORBIDDEN, friendlyMessage, e.getMessage(), request.getRequestURI());
	}

	@ExceptionHandler(CredentialsExpiredException.class)
	public ResponseEntity<CustomError> handleExpiredCredentials(CredentialsExpiredException e,
			HttpServletRequest request) {
		String friendlyMessage = "Sua senha expirou. Por favor, redefina sua senha.";
		return createErrorResponse(HttpStatus.FORBIDDEN, friendlyMessage, e.getMessage(), request.getRequestURI());
	}

	@ExceptionHandler(AuthenticationException.class)
	public ResponseEntity<CustomError> handleAuthenticationException(AuthenticationException e,
			HttpServletRequest request) {
		String friendlyMessage = "Falha na autenticação. Ocorreu um erro inesperado.";
		return createErrorResponse(HttpStatus.UNAUTHORIZED, friendlyMessage, e.getMessage(), request.getRequestURI());
	}

	private ResponseEntity<CustomError> createErrorResponse(HttpStatus status, String friendlyMessage,
			String developerMessage, String path) {
		System.err.println("Exceção de autenticação na URI: " + path + " - " + developerMessage);
		CustomError err = new CustomError(Instant.now(), status.value(), friendlyMessage, path);
		return ResponseEntity.status(status).body(err);
	}

	@ExceptionHandler(Exception.class)
	public ResponseEntity<CustomError> handleGenericException(Exception e, HttpServletRequest request) {
		HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
		String friendlyMessage = "Ocorreu um erro inesperado no servidor.";
		CustomError err = new CustomError(Instant.now(), status.value(), friendlyMessage, request.getRequestURI());
		return ResponseEntity.status(status).body(err);
	}
}
