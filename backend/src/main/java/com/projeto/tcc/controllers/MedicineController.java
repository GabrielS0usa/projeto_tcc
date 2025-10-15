package com.projeto.tcc.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.projeto.tcc.dto.MedicineDTO;
import com.projeto.tcc.services.MedicineService;

@RestController
@RequestMapping("/medicines")
public class MedicineController {

    @Autowired
    private MedicineService service;

    @PostMapping
    public ResponseEntity<MedicineDTO> create(@RequestBody MedicineDTO dto) {
        MedicineDTO created = service.create(dto);
        return ResponseEntity.ok(created);
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
}
