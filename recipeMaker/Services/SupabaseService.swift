//
//  SupabaseService.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/25/26.
//

import Foundation
import Supabase

// MARK: - Supabase Client

struct SupabaseService: Sendable {
    static let shared = SupabaseService()

    let client = SupabaseClient(
        supabaseURL: URL(string: "https://mwqlnhuhzdldleeguejh.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13cWxuaHVoemRsZGxlZWd1ZWpoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5MjA1NjUsImV4cCI6MjA5MDQ5NjU2NX0.d1LCgfOQ5XC1QWoeYwsRY65dw-6AQoTOivIG8gvupOw"
    )

    private init() {}
}

// MARK: - Database DTOs

struct SavedRecipeDTO: Codable {
    let id: Int?
    let userId: UUID
    let mealId: String
    let name: String
    let thumbUrl: String?
    let category: String?
    let area: String?
    let tags: [String]
    let dateSaved: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case mealId = "meal_id"
        case name
        case thumbUrl = "thumb_url"
        case category
        case area
        case tags
        case dateSaved = "date_saved"
    }

    func toDomain() -> SavedRecipe {
        SavedRecipe(
            mealId: mealId,
            name: name,
            thumbURL: thumbUrl,
            category: category,
            area: area,
            tags: Set(tags.compactMap { MealTag(rawValue: $0) }),
            dateSaved: dateSaved
        )
    }

    static func from(domain: SavedRecipe, userId: UUID) -> SavedRecipeDTO {
        SavedRecipeDTO(
            id: nil,
            userId: userId,
            mealId: domain.mealId,
            name: domain.name,
            thumbUrl: domain.thumbURL,
            category: domain.category,
            area: domain.area,
            tags: domain.tags.map { $0.rawValue },
            dateSaved: domain.dateSaved
        )
    }
}

struct UserRecipeDTO: Codable {
    let id: UUID
    let userId: UUID
    let name: String
    let category: String
    let area: String
    let instructions: String
    let imagePath: String?
    let tags: [String]
    let dateCreated: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case category
        case area
        case instructions
        case imagePath = "image_path"
        case tags
        case dateCreated = "date_created"
    }

    func toDomain(ingredients: [UserIngredient]) -> UserRecipe {
        UserRecipe(
            id: id,
            name: name,
            category: category,
            area: area,
            instructions: instructions,
            ingredients: ingredients,
            tags: Set(tags.compactMap { MealTag(rawValue: $0) }),
            imagePath: imagePath,
            dateCreated: dateCreated
        )
    }

    static func from(domain: UserRecipe, userId: UUID) -> UserRecipeDTO {
        UserRecipeDTO(
            id: domain.id,
            userId: userId,
            name: domain.name,
            category: domain.category,
            area: domain.area,
            instructions: domain.instructions,
            imagePath: domain.imagePath,
            tags: domain.tags.map { $0.rawValue },
            dateCreated: domain.dateCreated
        )
    }
}

struct UserIngredientDTO: Codable {
    let id: UUID
    let recipeId: UUID
    let name: String
    let measure: String
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case name
        case measure
        case sortOrder = "sort_order"
    }

    func toDomain() -> UserIngredient {
        UserIngredient(id: id, name: name, measure: measure)
    }

    static func from(domain: UserIngredient, recipeId: UUID, sortOrder: Int) -> UserIngredientDTO {
        UserIngredientDTO(
            id: domain.id,
            recipeId: recipeId,
            name: domain.name,
            measure: domain.measure,
            sortOrder: sortOrder
        )
    }
}

// MARK: - Saved Recipes CRUD

extension SupabaseService {

    func fetchSavedRecipes(userId: UUID) async throws -> [SavedRecipe] {
        let dtos: [SavedRecipeDTO] = try await client
            .from("saved_recipes")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        return dtos.map { $0.toDomain() }
    }

    func insertSavedRecipe(_ recipe: SavedRecipe, userId: UUID) async throws {
        let dto = SavedRecipeDTO.from(domain: recipe, userId: userId)
        try await client
            .from("saved_recipes")
            .insert(dto)
            .execute()
    }

    func deleteSavedRecipe(mealId: String, userId: UUID) async throws {
        try await client
            .from("saved_recipes")
            .delete()
            .eq("meal_id", value: mealId)
            .eq("user_id", value: userId)
            .execute()
    }

    func updateSavedRecipeTags(mealId: String, tags: Set<MealTag>, userId: UUID) async throws {
        try await client
            .from("saved_recipes")
            .update(["tags": tags.map { $0.rawValue }])
            .eq("meal_id", value: mealId)
            .eq("user_id", value: userId)
            .execute()
    }
}

// MARK: - User Recipes CRUD

extension SupabaseService {

    func fetchUserRecipes(userId: UUID) async throws -> [UserRecipe] {
        let recipeDTOs: [UserRecipeDTO] = try await client
            .from("user_recipes")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        guard !recipeDTOs.isEmpty else { return [] }

        let recipeIds = recipeDTOs.map { $0.id }
        let ingredientDTOs: [UserIngredientDTO] = try await client
            .from("user_ingredients")
            .select()
            .in("recipe_id", values: recipeIds)
            .order("sort_order")
            .execute()
            .value

        let ingredientsByRecipe = Dictionary(grouping: ingredientDTOs) { $0.recipeId }

        return recipeDTOs.map { dto in
            let ingredients = (ingredientsByRecipe[dto.id] ?? []).map { $0.toDomain() }
            return dto.toDomain(ingredients: ingredients)
        }
    }

    func insertUserRecipe(_ recipe: UserRecipe, userId: UUID) async throws {
        let dto = UserRecipeDTO.from(domain: recipe, userId: userId)
        try await client
            .from("user_recipes")
            .insert(dto)
            .execute()

        let ingredientDTOs = recipe.ingredients.enumerated().map { index, ing in
            UserIngredientDTO.from(domain: ing, recipeId: recipe.id, sortOrder: index)
        }
        if !ingredientDTOs.isEmpty {
            try await client
                .from("user_ingredients")
                .insert(ingredientDTOs)
                .execute()
        }
    }

    func updateUserRecipe(_ recipe: UserRecipe, userId: UUID) async throws {
        let dto = UserRecipeDTO.from(domain: recipe, userId: userId)
        try await client
            .from("user_recipes")
            .update(dto)
            .eq("id", value: recipe.id)
            .eq("user_id", value: userId)
            .execute()

        // Replace ingredients: delete old, insert new
        try await client
            .from("user_ingredients")
            .delete()
            .eq("recipe_id", value: recipe.id)
            .execute()

        let ingredientDTOs = recipe.ingredients.enumerated().map { index, ing in
            UserIngredientDTO.from(domain: ing, recipeId: recipe.id, sortOrder: index)
        }
        if !ingredientDTOs.isEmpty {
            try await client
                .from("user_ingredients")
                .insert(ingredientDTOs)
                .execute()
        }
    }

    func deleteUserRecipe(id: UUID, userId: UUID) async throws {
        try await client
            .from("user_ingredients")
            .delete()
            .eq("recipe_id", value: id)
            .execute()

        try await client
            .from("user_recipes")
            .delete()
            .eq("id", value: id)
            .eq("user_id", value: userId)
            .execute()
    }

    func updateUserRecipeTags(id: UUID, tags: Set<MealTag>, userId: UUID) async throws {
        try await client
            .from("user_recipes")
            .update(["tags": tags.map { $0.rawValue }])
            .eq("id", value: id)
            .eq("user_id", value: userId)
            .execute()
    }
}

// MARK: - Storage (Recipe Images)

extension SupabaseService {

    func uploadImage(data: Data, userId: UUID, recipeId: UUID) async throws -> String {
        let path = "\(userId)/\(recipeId).jpg"
        try await client.storage
            .from("recipe-images")
            .upload(path, data: data, options: .init(contentType: "image/jpeg", upsert: true))
        return path
    }

    func downloadImage(path: String) async throws -> Data {
        try await client.storage
            .from("recipe-images")
            .download(path: path)
    }

    func deleteStorageImage(path: String) async throws {
        _ = try await client.storage
            .from("recipe-images")
            .remove(paths: [path])
    }
}
