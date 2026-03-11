//
//  CookbookStore.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import Foundation
import SwiftUI

@Observable
final class CookbookStore {
    private static let savedRecipesKey = "savedRecipes"
    private static let userRecipesKey = "userRecipes"

    var savedRecipes: [SavedRecipe] = [] {
        didSet { persistSavedRecipes() }
    }

    var userRecipes: [UserRecipe] = [] {
        didSet { persistUserRecipes() }
    }

    init() {
        loadSavedRecipes()
        loadUserRecipes()
    }

    // MARK: - Saved Recipes

    func isSaved(mealId: String) -> Bool {
        savedRecipes.contains { $0.mealId == mealId }
    }

    func save(meal: MealDTO) {
        guard !isSaved(mealId: meal.idMeal) else { return }
        let recipe = SavedRecipe(
            mealId: meal.idMeal,
            name: meal.strMeal,
            thumbURL: meal.strMealThumb,
            category: meal.strCategory,
            area: meal.strArea,
            tags: [],
            dateSaved: Date()
        )
        savedRecipes.append(recipe)
    }

    func remove(mealId: String) {
        savedRecipes.removeAll { $0.mealId == mealId }
    }

    func toggleSaved(meal: MealDTO) {
        if isSaved(mealId: meal.idMeal) {
            remove(mealId: meal.idMeal)
        } else {
            save(meal: meal)
        }
    }

    func toggleTag(_ tag: MealTag, for mealId: String) {
        guard let index = savedRecipes.firstIndex(where: { $0.mealId == mealId }) else { return }
        if savedRecipes[index].tags.contains(tag) {
            savedRecipes[index].tags.remove(tag)
        } else {
            savedRecipes[index].tags.insert(tag)
        }
    }

    func tags(for mealId: String) -> Set<MealTag> {
        savedRecipes.first { $0.mealId == mealId }?.tags ?? []
    }

    // MARK: - User Recipes

    func addUserRecipe(_ recipe: UserRecipe) {
        userRecipes.append(recipe)
    }

    func updateUserRecipe(_ recipe: UserRecipe) {
        guard let index = userRecipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        userRecipes[index] = recipe
    }

    func removeUserRecipe(id: UUID) {
        userRecipes.removeAll { $0.id == id }
    }

    func toggleUserRecipeTag(_ tag: MealTag, for recipeId: UUID) {
        guard let index = userRecipes.firstIndex(where: { $0.id == recipeId }) else { return }
        if userRecipes[index].tags.contains(tag) {
            userRecipes[index].tags.remove(tag)
        } else {
            userRecipes[index].tags.insert(tag)
        }
    }

    func userRecipeTags(for recipeId: UUID) -> Set<MealTag> {
        userRecipes.first { $0.id == recipeId }?.tags ?? []
    }

    // MARK: - Persistence

    private func persistSavedRecipes() {
        if let data = try? JSONEncoder().encode(savedRecipes) {
            UserDefaults.standard.set(data, forKey: Self.savedRecipesKey)
        }
    }

    private func persistUserRecipes() {
        if let data = try? JSONEncoder().encode(userRecipes) {
            UserDefaults.standard.set(data, forKey: Self.userRecipesKey)
        }
    }

    private func loadSavedRecipes() {
        if let data = UserDefaults.standard.data(forKey: Self.savedRecipesKey),
           let recipes = try? JSONDecoder().decode([SavedRecipe].self, from: data) {
            savedRecipes = recipes
        }
    }

    private func loadUserRecipes() {
        if let data = UserDefaults.standard.data(forKey: Self.userRecipesKey),
           let recipes = try? JSONDecoder().decode([UserRecipe].self, from: data) {
            userRecipes = recipes
        }
    }
}
