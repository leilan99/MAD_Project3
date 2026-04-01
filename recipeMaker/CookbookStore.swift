//
//  CookbookStore.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import Foundation
import SwiftUI
import UIKit

@Observable
final class CookbookStore {
    var savedRecipes: [SavedRecipe] = []
    var userRecipes: [UserRecipe] = []
    var userId: UUID?

    private let service = SupabaseService.shared

    // MARK: - Load All

    func loadAll() async throws {
        guard let userId else { return }
        let saved = try await service.fetchSavedRecipes(userId: userId)
        let user = try await service.fetchUserRecipes(userId: userId)
        await MainActor.run {
            self.savedRecipes = saved
            self.userRecipes = user
        }
    }

    // MARK: - Saved Recipes

    func isSaved(mealId: String) -> Bool {
        savedRecipes.contains { $0.mealId == mealId }
    }

    func save(meal: MealDTO) async throws {
        guard let userId, !isSaved(mealId: meal.idMeal) else { return }
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
        try await service.insertSavedRecipe(recipe, userId: userId)
    }

    func remove(mealId: String) async throws {
        guard let userId else { return }
        savedRecipes.removeAll { $0.mealId == mealId }
        try await service.deleteSavedRecipe(mealId: mealId, userId: userId)
    }

    func toggleSaved(meal: MealDTO) async throws {
        if isSaved(mealId: meal.idMeal) {
            try await remove(mealId: meal.idMeal)
        } else {
            try await save(meal: meal)
        }
    }

    func toggleTag(_ tag: MealTag, for mealId: String) async throws {
        guard let userId,
              let index = savedRecipes.firstIndex(where: { $0.mealId == mealId }) else { return }
        if savedRecipes[index].tags.contains(tag) {
            savedRecipes[index].tags.remove(tag)
        } else {
            savedRecipes[index].tags.insert(tag)
        }
        try await service.updateSavedRecipeTags(
            mealId: mealId, tags: savedRecipes[index].tags, userId: userId
        )
    }

    func tags(for mealId: String) -> Set<MealTag> {
        savedRecipes.first { $0.mealId == mealId }?.tags ?? []
    }

    // MARK: - User Recipes

    func addUserRecipe(_ recipe: UserRecipe) async throws {
        guard let userId else { return }
        var newRecipe = recipe
        let dbId = try await service.insertUserRecipe(recipe, userId: userId)
        newRecipe.dbId = dbId
        userRecipes.append(newRecipe)
    }

    func updateUserRecipe(_ recipe: UserRecipe) async throws {
        guard let userId,
              let index = userRecipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        userRecipes[index] = recipe
        try await service.updateUserRecipe(recipe, userId: userId)
    }

    func removeUserRecipe(id: UUID) async throws {
        guard let userId else { return }
        if let recipe = userRecipes.first(where: { $0.id == id }) {
            if let imagePath = recipe.imagePath {
                deleteImageLocally(path: imagePath)
                try? await service.deleteStorageImage(path: imagePath)
            }
            if let dbId = recipe.dbId {
                try await service.deleteUserRecipe(dbId: dbId, userId: userId)
            }
        }
        userRecipes.removeAll { $0.id == id }
    }

    func toggleUserRecipeTag(_ tag: MealTag, for recipeId: UUID) async throws {
        guard let userId,
              let index = userRecipes.firstIndex(where: { $0.id == recipeId }) else { return }
        if userRecipes[index].tags.contains(tag) {
            userRecipes[index].tags.remove(tag)
        } else {
            userRecipes[index].tags.insert(tag)
        }
        guard let dbId = userRecipes[index].dbId else { return }
        try await service.updateUserRecipeTags(
            dbId: dbId, tags: userRecipes[index].tags, userId: userId
        )
    }

    func userRecipeTags(for recipeId: UUID) -> Set<MealTag> {
        userRecipes.first { $0.id == recipeId }?.tags ?? []
    }

    // MARK: - Recipe Images

    private static var imagesDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = documents.appendingPathComponent("RecipeImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func saveImage(_ data: Data, for recipeId: UUID) async throws -> String? {
        guard let userId else { return nil }
        guard let uiImage = UIImage(data: data),
              let compressed = uiImage.jpegData(compressionQuality: 0.7) else { return nil }

        // Save locally
        let filename = "\(recipeId.uuidString).jpg"
        let localURL = Self.imagesDirectory.appendingPathComponent(filename)
        try compressed.write(to: localURL)

        // Upload to Supabase Storage
        let storagePath = try await service.uploadImage(data: compressed, userId: userId, recipeId: recipeId)
        return storagePath
    }

    func loadImage(path: String) -> UIImage? {
        // Try local cache first
        let filename = URL(string: path)?.lastPathComponent ?? path
        let localURL = Self.imagesDirectory.appendingPathComponent(filename)
        if let data = try? Data(contentsOf: localURL) {
            return UIImage(data: data)
        }
        return nil
    }

    func fetchImageIfNeeded(path: String) async throws -> UIImage? {
        if let cached = loadImage(path: path) { return cached }

        // Download from Supabase Storage and cache locally
        let data = try await service.downloadImage(path: path)
        let filename = URL(string: path)?.lastPathComponent ?? path
        let localURL = Self.imagesDirectory.appendingPathComponent(filename)
        try? data.write(to: localURL)
        return UIImage(data: data)
    }

    func deleteStorageImage(path: String) async throws {
        deleteImageLocally(path: path)
        try await service.deleteStorageImage(path: path)
    }

    private func deleteImageLocally(path: String) {
        let filename = URL(string: path)?.lastPathComponent ?? path
        let localURL = Self.imagesDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: localURL)
    }

    // MARK: - Migration from UserDefaults

    func migrateFromUserDefaultsIfNeeded() async throws {
        guard let userId else { return }
        let migrationKey = "hasCompletedSupabaseMigration"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }

        // Migrate saved recipes
        if let data = UserDefaults.standard.data(forKey: "savedRecipes"),
           let localSaved = try? JSONDecoder().decode([SavedRecipe].self, from: data) {
            for recipe in localSaved {
                try? await service.insertSavedRecipe(recipe, userId: userId)
            }
        }

        // Migrate user recipes (including images)
        if let data = UserDefaults.standard.data(forKey: "userRecipes"),
           let localUser = try? JSONDecoder().decode([UserRecipe].self, from: data) {
            for var recipe in localUser {
                // Upload local image to Supabase Storage if exists
                if let localPath = recipe.imagePath {
                    let localURL = Self.imagesDirectory.appendingPathComponent(localPath)
                    if let imageData = try? Data(contentsOf: localURL) {
                        let storagePath = try? await service.uploadImage(
                            data: imageData, userId: userId, recipeId: recipe.id
                        )
                        recipe.imagePath = storagePath
                    }
                }
                try? await service.insertUserRecipe(recipe, userId: userId)
            }
        }

        UserDefaults.standard.set(true, forKey: migrationKey)
        UserDefaults.standard.removeObject(forKey: "savedRecipes")
        UserDefaults.standard.removeObject(forKey: "userRecipes")
    }
}
