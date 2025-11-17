package com.projeto.tcc.dto;

import java.time.LocalDate;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

public class NutritionalEntryRequest {
   
    @NotNull(message = "Data é obrigatória")
    private LocalDate date;
    
    @NotBlank(message = "Nome do alimento é obrigatório")
    private String foodName;
    
    @PositiveOrZero(message = "Calorias devem ser zero ou positivas")
    private double calories;
    
    @PositiveOrZero(message = "Proteína deve ser zero ou positiva")
    private double protein;
    
    @PositiveOrZero(message = "Carboidratos devem ser zero ou positivos")
    private double carbs;
    
    @PositiveOrZero(message = "Gordura deve ser zero ou positiva")
    private double fat;
    
    @NotBlank(message = "Tipo de refeição é obrigatório")
    private String mealType;

    public NutritionalEntryRequest() {}

    public NutritionalEntryRequest(LocalDate date, String foodName, String mealType, 
                                  double calories, double protein, double carbs, double fat) {
        this.date = date;
        this.foodName = foodName;
        this.mealType = mealType;
        this.calories = calories;
        this.protein = protein;
        this.carbs = carbs;
        this.fat = fat;
    }

    // Getters and Setters
    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }
    
    public String getFoodName() { return foodName; }
    public void setFoodName(String foodName) { this.foodName = foodName; }
    
    public double getCalories() { return calories; }
    public void setCalories(double calories) { this.calories = calories; }
    
    public double getProtein() { return protein; }
    public void setProtein(double protein) { this.protein = protein; }
    
    public double getCarbs() { return carbs; }
    public void setCarbs(double carbs) { this.carbs = carbs; }
    
    public double getFat() { return fat; }
    public void setFat(double fat) { this.fat = fat; }
    
    public String getMealType() { return mealType; }
    public void setMealType(String mealType) { this.mealType = mealType; }
}