package com.projeto.tcc.controllers;

import java.net.URI;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import com.projeto.tcc.dto.MedicationTaskDTO;
import com.projeto.tcc.dto.MedicineDTO;
import com.projeto.tcc.services.MedicineService;

@RestController
@RequestMapping("/medicines")
public class MedicineController {

    @Autowired
    private MedicineService service;

    @PostMapping("/save")
    public ResponseEntity<MedicineDTO> create(@RequestBody MedicineDTO dto) {
        MedicineDTO created = service.create(dto);
        URI uri = ServletUriComponentsBuilder.fromCurrentRequest().path("/{id}").buildAndExpand(created.getId()).toUri();
		return ResponseEntity.created(uri).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<MedicineDTO> update(@PathVariable Long id, @RequestBody MedicineDTO dto) {
        MedicineDTO updated = service.update(id, dto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/me")
    public ResponseEntity<List<MedicineDTO>> findMyMedicines() {
        List<MedicineDTO> list = service.findMyMedicines();
        return ResponseEntity.ok(list);
    }
    
    @GetMapping("/tasks/today")
    public ResponseEntity<List<MedicationTaskDTO>> findTodayTasks() {
        List<MedicationTaskDTO> list = service.findTodayTasks();
        return ResponseEntity.ok(list);
    }

    @PutMapping("/tasks/{id}")
    public ResponseEntity<Void> updateTaskStatus(@PathVariable Long id, @RequestBody Map<String, Boolean> body) {
        boolean taken = body.get("taken");
        service.updateTaskStatus(id, taken);
        return ResponseEntity.ok().build();
    }
}
