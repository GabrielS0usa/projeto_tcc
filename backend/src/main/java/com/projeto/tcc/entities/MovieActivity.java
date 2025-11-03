package com.projeto.tcc.entities;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.Objects;

@Entity
@Table(name = "tb_movie_activity")
public class MovieActivity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String movieTitle;

    @Column
    private String genre;

    @Column(nullable = false)
    private Integer rating; // 1-5 stars

    @Column(nullable = false)
    private LocalDate watchDate;

    @Column(columnDefinition = "TEXT")
    private String review;

    @Column(nullable = false)
    private Boolean isWatched = true;

    public MovieActivity() {
    }

    public MovieActivity(Long id, User user, String movieTitle, String genre, 
                        Integer rating, LocalDate watchDate, String review, Boolean isWatched) {
        this.id = id;
        this.user = user;
        this.movieTitle = movieTitle;
        this.genre = genre;
        this.rating = rating;
        this.watchDate = watchDate;
        this.review = review;
        this.isWatched = isWatched;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getMovieTitle() {
        return movieTitle;
    }

    public void setMovieTitle(String movieTitle) {
        this.movieTitle = movieTitle;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(Integer rating) {
        this.rating = rating;
    }

    public LocalDate getWatchDate() {
        return watchDate;
    }

    public void setWatchDate(LocalDate watchDate) {
        this.watchDate = watchDate;
    }

    public String getReview() {
        return review;
    }

    public void setReview(String review) {
        this.review = review;
    }

    public Boolean getIsWatched() {
        return isWatched;
    }

    public void setIsWatched(Boolean isWatched) {
        this.isWatched = isWatched;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        MovieActivity that = (MovieActivity) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
