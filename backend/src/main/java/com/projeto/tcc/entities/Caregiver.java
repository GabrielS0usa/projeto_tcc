package com.projeto.tcc.entities;

import jakarta.persistence.*;
import java.util.Objects;

@Entity
@Table(name = "tb_caregiver")
public class Caregiver {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    public Caregiver() {}

    public Caregiver(Long id, String name, String email, User user) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.user = user;
    }

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o)
			return true;
		if (o == null || getClass() != o.getClass())
			return false;
		Caregiver caregiver = (Caregiver) o;
		return Objects.equals(id, caregiver.id);
	}

	@Override
	public int hashCode() {
		return Objects.hash(id);
	}
}