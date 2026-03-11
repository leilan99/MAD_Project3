//
//  MealService.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import Foundation

actor MealService {
    static let shared = MealService()
    private let baseURL = "https://www.themealdb.com/api/json/v1/1"

    private init() {}

    // MARK: - Categories

    func fetchCategories() async throws -> [CategoryDTO] {
        let url = URL(string: "\(baseURL)/categories.php")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(CategoriesResponse.self, from: data)
        return response.categories
    }

    // MARK: - Meals by Category

    func fetchMeals(forCategory category: String) async throws -> [MealSummaryDTO] {
        let encoded = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category
        let url = URL(string: "\(baseURL)/filter.php?c=\(encoded)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealSummaryResponse.self, from: data)
        return response.meals ?? []
    }

    // MARK: - Meals by Area/Cuisine

    func fetchMeals(forArea area: String) async throws -> [MealSummaryDTO] {
        let encoded = area.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? area
        let url = URL(string: "\(baseURL)/filter.php?a=\(encoded)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealSummaryResponse.self, from: data)
        return response.meals ?? []
    }

    // MARK: - Meals by Ingredient

    func fetchMeals(forIngredient ingredient: String) async throws -> [MealSummaryDTO] {
        let encoded = ingredient.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ingredient
        let url = URL(string: "\(baseURL)/filter.php?i=\(encoded)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealSummaryResponse.self, from: data)
        return response.meals ?? []
    }

    // MARK: - Meal Detail

    func fetchMealDetail(id: String) async throws -> MealDTO? {
        let url = URL(string: "\(baseURL)/lookup.php?i=\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealsResponse.self, from: data)
        return response.meals?.first
    }

    // MARK: - Random Meal

    func fetchRandomMeal() async throws -> MealDTO? {
        let url = URL(string: "\(baseURL)/random.php")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealsResponse.self, from: data)
        return response.meals?.first
    }

    // MARK: - Search

    func searchMeals(query: String) async throws -> [MealDTO] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/search.php?s=\(encoded)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealsResponse.self, from: data)
        return response.meals ?? []
    }

    // MARK: - Areas (Cuisines)

    func fetchAreas() async throws -> [AreaDTO] {
        let url = URL(string: "\(baseURL)/list.php?a=list")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AreaListResponse.self, from: data)
        return response.meals
    }

    // MARK: - Ingredients

    func fetchIngredients() async throws -> [IngredientDTO] {
        let url = URL(string: "\(baseURL)/list.php?i=list")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(IngredientListResponse.self, from: data)
        return response.meals
    }
}
