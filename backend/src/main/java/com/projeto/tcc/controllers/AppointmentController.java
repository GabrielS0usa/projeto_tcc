package com.projeto.tcc.controllers;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping; 
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus; 
import org.springframework.web.bind.annotation.RestController;

import com.projeto.tcc.dto.AppointmentDTO;
import com.projeto.tcc.services.AppointmentService;

@RestController
@RequestMapping("/appointments") 
@CrossOrigin(origins = "*")
public class AppointmentController {

    @Autowired 
    private AppointmentService service;

    @GetMapping
    public ResponseEntity<List<AppointmentDTO>> findAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED) 
    public ResponseEntity<AppointmentDTO> save(@RequestBody AppointmentDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.save(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<AppointmentDTO> update(@PathVariable Long id, @RequestBody AppointmentDTO dto) {
        AppointmentDTO updatedDto = service.update(id, dto);
        return ResponseEntity.ok(updatedDto);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT) 
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }


    @GetMapping("/day/{date}")
    public ResponseEntity<List<AppointmentDTO>> getAppointmentsForDay(@PathVariable String date) {
        LocalDate parsedDate = LocalDate.parse(date); 
        LocalDateTime start = parsedDate.atStartOfDay();
        LocalDateTime end = parsedDate.atTime(23, 59, 59);
        return ResponseEntity.ok(service.getAppointmentsForDay(start, end));
    }
}
