package com.projeto.tcc.entities;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.Objects;

@Entity
@Table(name = "tb_reading_activity")
public class ReadingActivity {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "user_id", nullable = false)
	private User user;

	@Column(nullable = false)
	private String bookTitle;

	@Column
	private String author;

	@Column(nullable = false)
	private Integer totalPages;

	@Column(nullable = false)
	private Integer currentPage;

	@Column(columnDefinition = "TEXT")
	private String notes;

	@Column(nullable = false)
	private LocalDate startDate;

	@Column
	private LocalDate completionDate;

	@Column(nullable = false)
	private Boolean isCompleted = false;

	public ReadingActivity() {
	}

	public ReadingActivity(Long id, User user, String bookTitle, String author, Integer totalPages, Integer currentPage,
			String notes, LocalDate startDate, LocalDate completionDate, Boolean isCompleted) {
		this.id = id;
		this.user = user;
		this.bookTitle = bookTitle;
		this.author = author;
		this.totalPages = totalPages;
		this.currentPage = currentPage;
		this.notes = notes;
		this.startDate = startDate;
		this.completionDate = completionDate;
		this.isCompleted = isCompleted;
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

	public String getBookTitle() {
		return bookTitle;
	}

	public void setBookTitle(String bookTitle) {
		this.bookTitle = bookTitle;
	}

	public String getAuthor() {
		return author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public Integer getTotalPages() {
		return totalPages;
	}

	public void setTotalPages(Integer totalPages) {
		this.totalPages = totalPages;
	}

	public Integer getCurrentPage() {
		return currentPage;
	}

	public void setCurrentPage(Integer currentPage) {
		this.currentPage = currentPage;
	}

	public String getNotes() {
		return notes;
	}

	public void setNotes(String notes) {
		this.notes = notes;
	}

	public LocalDate getStartDate() {
		return startDate;
	}

	public void setStartDate(LocalDate startDate) {
		this.startDate = startDate;
	}

	public LocalDate getCompletionDate() {
		return completionDate;
	}

	public void setCompletionDate(LocalDate completionDate) {
		this.completionDate = completionDate;
	}

	public Boolean getIsCompleted() {
		return isCompleted;
	}

	public void setIsCompleted(Boolean isCompleted) {
		this.isCompleted = isCompleted;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o)
			return true;
		if (o == null || getClass() != o.getClass())
			return false;
		ReadingActivity that = (ReadingActivity) o;
		return Objects.equals(id, that.id);
	}

	@Override
	public int hashCode() {
		return Objects.hash(id);
	}
}
