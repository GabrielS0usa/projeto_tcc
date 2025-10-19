package com.projeto.tcc.services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.projeto.tcc.dto.MedicineDTO;
import com.projeto.tcc.entities.Medicine;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.repositories.MedicineRepository;
import com.projeto.tcc.repositories.UserRepository;

import jakarta.transaction.Transactional;

@Service
public class MedicineService {

    @Autowired
    private MedicineRepository repository;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public MedicineDTO create(MedicineDTO dto) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        Medicine entity = new Medicine();
        copyDtoToEntity(dto, entity);
        entity.setUser(user);

        repository.save(entity);
        return new MedicineDTO(entity);
    }

    @Transactional
    public MedicineDTO update(Long id, MedicineDTO dto) {
        Medicine entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Remédio não encontrado"));
        copyDtoToEntity(dto, entity);
        repository.save(entity);
        return new MedicineDTO(entity);
    }

    @Transactional
    public void delete(Long id) {
        repository.deleteById(id);
    }

    @Transactional
    public List<MedicineDTO> findMyMedicines() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        return repository.findByUserOrderByStartDateAscStartTimeAsc(user)
                .stream().map(MedicineDTO::new).collect(Collectors.toList());
    }

    private void copyDtoToEntity(MedicineDTO dto, Medicine entity) {
        entity.setName(dto.getName());
        entity.setDose(dto.getDose());
        entity.setStartTime(dto.getStartTime());
        entity.setIntervalHours(dto.getIntervalHours());
        entity.setDurationDays(dto.getDurationDays());
        entity.setStartDate(dto.getStartDate());
    }
}