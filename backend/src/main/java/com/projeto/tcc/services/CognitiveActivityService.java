package com.projeto.tcc.services;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.projeto.tcc.dto.CognitiveActivityStatsDTO;
import com.projeto.tcc.dto.CrosswordActivityDTO;
import com.projeto.tcc.dto.MovieActivityDTO;
import com.projeto.tcc.dto.ReadingActivityDTO;
import com.projeto.tcc.entities.CrosswordActivity;
import com.projeto.tcc.entities.MovieActivity;
import com.projeto.tcc.entities.ReadingActivity;
import com.projeto.tcc.entities.User;
import com.projeto.tcc.repositories.CrosswordActivityRepository;
import com.projeto.tcc.repositories.MovieActivityRepository;
import com.projeto.tcc.repositories.ReadingActivityRepository;
import com.projeto.tcc.repositories.UserRepository;
import com.projeto.tcc.services.exceptions.ResourceNotFoundException;

@Service
public class CognitiveActivityService {

    @Autowired
    private ReadingActivityRepository readingRepository;

    @Autowired
    private CrosswordActivityRepository crosswordRepository;

    @Autowired
    private MovieActivityRepository movieRepository;

    @Autowired
    private UserRepository userRepository;

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
    }

    @Transactional(readOnly = true)
    public List<ReadingActivityDTO> findAllReadingActivities() {
        User user = getCurrentUser();
        List<ReadingActivity> list = readingRepository.findByUserOrderByStartDateDesc(user);
        return list.stream().map(ReadingActivityDTO::new).collect(Collectors.toList());
    }

    @Transactional
    public ReadingActivityDTO saveReadingActivity(ReadingActivityDTO dto) {
        User user = getCurrentUser();
        ReadingActivity entity = new ReadingActivity();
        copyReadingDtoToEntity(dto, entity);
        entity.setUser(user);

        if (entity.getCurrentPage() >= entity.getTotalPages()) {
            entity.setIsCompleted(true);
            if (entity.getCompletionDate() == null) {
                entity.setCompletionDate(LocalDate.now());
            }
        }

        entity = readingRepository.save(entity);
        return new ReadingActivityDTO(entity);
    }

    @Transactional
    public ReadingActivityDTO updateReadingActivity(Long id, ReadingActivityDTO dto) {
        User user = getCurrentUser();
        ReadingActivity entity = readingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Atividade de leitura não encontrada"));

        if (!entity.getUser().equals(user)) {
            throw new SecurityException("Acesso negado");
        }

        copyReadingDtoToEntity(dto, entity);
        
        if (entity.getCurrentPage() >= entity.getTotalPages()) {
            entity.setIsCompleted(true);
            if (entity.getCompletionDate() == null) {
                entity.setCompletionDate(LocalDate.now());
            }
        }
        
        entity = readingRepository.save(entity);
        return new ReadingActivityDTO(entity);
    }

    @Transactional
    public void deleteReadingActivity(Long id) {
        User user = getCurrentUser();
        ReadingActivity entity = readingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Atividade de leitura não encontrada"));

        if (!entity.getUser().equals(user)) {
            throw new SecurityException("Acesso negado");
        }

        readingRepository.deleteById(id);
    }

    private void copyReadingDtoToEntity(ReadingActivityDTO dto, ReadingActivity entity) {
        entity.setBookTitle(dto.bookTitle());
        entity.setAuthor(dto.author());
        entity.setTotalPages(dto.totalPages());
        entity.setCurrentPage(dto.currentPage());
        entity.setNotes(dto.notes());
        entity.setStartDate(dto.startDate());
        entity.setCompletionDate(dto.completionDate());
        entity.setIsCompleted(dto.isCompleted() != null ? dto.isCompleted() : false);
    }

    @Transactional(readOnly = true)
    public List<CrosswordActivityDTO> findAllCrosswordActivities() {
        User user = getCurrentUser();
        List<CrosswordActivity> list = crosswordRepository.findByUserOrderByDateDesc(user);
        return list.stream().map(CrosswordActivityDTO::new).collect(Collectors.toList());
    }

    @Transactional
    public CrosswordActivityDTO saveCrosswordActivity(CrosswordActivityDTO dto) {
        User user = getCurrentUser();
        CrosswordActivity entity = new CrosswordActivity();
        copyCrosswordDtoToEntity(dto, entity);
        entity.setUser(user);
        entity = crosswordRepository.save(entity);
        return new CrosswordActivityDTO(entity);
    }

    @Transactional
    public CrosswordActivityDTO updateCrosswordActivity(Long id, CrosswordActivityDTO dto) {
        User user = getCurrentUser();
        CrosswordActivity entity = crosswordRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Atividade de palavras cruzadas não encontrada"));

        if (!entity.getUser().equals(user)) {
            throw new SecurityException("Acesso negado");
        }

        copyCrosswordDtoToEntity(dto, entity);
        entity = crosswordRepository.save(entity);
        return new CrosswordActivityDTO(entity);
    }

    @Transactional
    public void deleteCrosswordActivity(Long id) {
        User user = getCurrentUser();
        CrosswordActivity entity = crosswordRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Atividade de palavras cruzadas não encontrada"));

        if (!entity.getUser().equals(user)) {
            throw new SecurityException("Acesso negado");
        }

        crosswordRepository.deleteById(id);
    }

    private void copyCrosswordDtoToEntity(CrosswordActivityDTO dto, CrosswordActivity entity) {
        entity.setPuzzleName(dto.puzzleName());
        entity.setDifficulty(dto.difficulty());
        entity.setDate(dto.date());
        entity.setTimeSpentMinutes(dto.timeSpentMinutes());
        entity.setIsCompleted(dto.isCompleted() != null ? dto.isCompleted() : false);
        entity.setNotes(dto.notes());
    }

    @Transactional(readOnly = true)
    public List<MovieActivityDTO> findAllMovieActivities() {
        User user = getCurrentUser();
        List<MovieActivity> list = movieRepository.findByUserOrderByWatchDateDesc(user);
        return list.stream().map(MovieActivityDTO::new).collect(Collectors.toList());
    }

    @Transactional
    public MovieActivityDTO saveMovieActivity(MovieActivityDTO dto) {
        User user = getCurrentUser();
        MovieActivity entity = new MovieActivity();
        copyMovieDtoToEntity(dto, entity);
        entity.setUser(user);
        entity = movieRepository.save(entity);
        return new MovieActivityDTO(entity);
    }

    @Transactional
    public MovieActivityDTO updateMovieActivity(Long id, MovieActivityDTO dto) {
        User user = getCurrentUser();
        MovieActivity entity = movieRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Atividade de filme não encontrada"));

        if (!entity.getUser().equals(user)) {
            throw new SecurityException("Acesso negado");
        }

        copyMovieDtoToEntity(dto, entity);
        entity = movieRepository.save(entity);
        return new MovieActivityDTO(entity);
    }

    @Transactional
    public void deleteMovieActivity(Long id) {
        User user = getCurrentUser();
        MovieActivity entity = movieRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Atividade de filme não encontrada"));

        if (!entity.getUser().equals(user)) {
            throw new SecurityException("Acesso negado");
        }

        movieRepository.deleteById(id);
    }

    private void copyMovieDtoToEntity(MovieActivityDTO dto, MovieActivity entity) {
        entity.setMovieTitle(dto.movieTitle());
        entity.setGenre(dto.genre());
        entity.setRating(dto.rating());
        entity.setWatchDate(dto.watchDate());
        entity.setReview(dto.review());
        entity.setIsWatched(dto.isWatched() != null ? dto.isWatched() : true);
    }

    @Transactional(readOnly = true)
    public CognitiveActivityStatsDTO getStatistics() {
        User user = getCurrentUser();
        
        Long booksRead = readingRepository.countCompletedByUser(user);
        Long crosswordsCompleted = crosswordRepository.countCompletedByUser(user);
        Long moviesWatched = movieRepository.countWatchedByUser(user);

        Integer weeklyStreak = calculateWeeklyStreak(user);

        return new CognitiveActivityStatsDTO(booksRead, crosswordsCompleted, moviesWatched, weeklyStreak);
    }

    private Integer calculateWeeklyStreak(User user) {
        LocalDate today = LocalDate.now();
        LocalDate weekAgo = today.minusDays(7);
        
        List<ReadingActivity> recentReading = readingRepository.findByUserOrderByStartDateDesc(user)
                .stream()
                .filter(r -> !r.getStartDate().isBefore(weekAgo))
                .collect(Collectors.toList());
        
        List<CrosswordActivity> recentCrosswords = crosswordRepository.findByUserOrderByDateDesc(user)
                .stream()
                .filter(c -> !c.getDate().isBefore(weekAgo))
                .collect(Collectors.toList());
        
        List<MovieActivity> recentMovies = movieRepository.findByUserOrderByWatchDateDesc(user)
                .stream()
                .filter(m -> !m.getWatchDate().isBefore(weekAgo))
                .collect(Collectors.toList());
        
        int streak = 0;
        for (int i = 0; i < 7; i++) {
            LocalDate checkDate = today.minusDays(i);
            boolean hasActivity = false;
            
            hasActivity = recentReading.stream().anyMatch(r -> r.getStartDate().equals(checkDate)) ||
                         recentCrosswords.stream().anyMatch(c -> c.getDate().equals(checkDate)) ||
                         recentMovies.stream().anyMatch(m -> m.getWatchDate().equals(checkDate));
            
            if (hasActivity) {
                streak++;
            } else if (i > 0) {
                break;
            }
        }
        
        return streak;
    }
}
