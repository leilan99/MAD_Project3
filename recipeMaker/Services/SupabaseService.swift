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

// MARK: - Database DTOs (matched to actual Supabase schema)

// saved_recipes: id (bigint auto), recipe_id (text), recipe_name (text),
//   thumb_url, category, area, date_saved, user_id (uuid), tags (text[])

struct SavedRecipeRow: Codable {
    let id: Int?
    let recipeId: String
    let recipeName: String
    let thumbUrl: String?
    let category: String?
    let area: String?
    let tags: [String]
    let dateSaved: String?

    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case recipeName = "recipe_name"
        case thumbUrl = "thumb_url"
        case category
        case area
        case tags
        case dateSaved = "date_saved"
    }

    func toDomain() -> SavedRecipe {
        SavedRecipe(
            mealId: recipeId,
            name: recipeName,
            thumbURL: thumbUrl,
            category: category,
            area: area,
            tags: Set(tags.compactMap { MealTag(rawValue: $0) }),
            dateSaved: Date()
        )
    }
}

/// For INSERT — omit id (auto-generated) and user_id (defaults to auth.uid())
struct SavedRecipeInsert: Codable {
    let recipeId: String
    let recipeName: String
    let thumbUrl: String?
    let category: String?
    let area: String?
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case recipeId = "recipe_id"
        case recipeName = "recipe_name"
        case thumbUrl = "thumb_url"
        case category
        case area
        case tags
    }

    static func from(domain: SavedRecipe) -> SavedRecipeInsert {
        SavedRecipeInsert(
            recipeId: domain.mealId,
            recipeName: domain.name,
            thumbUrl: domain.thumbURL,
            category: domain.category,
            area: domain.area,
            tags: domain.tags.map { $0.rawValue }
        )
    }
}

// user_recipes: id (bigint auto), name, category, area, instructions,
//   image_path, date_created, user_id (uuid), tags (text[])

struct UserRecipeRow: Codable {
    let id: Int
    let name: String
    let category: String
    let area: String
    let instructions: String
    let imagePath: String?
    let tags: [String]
    let dateCreated: String?
    let shared: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case area
        case instructions
        case imagePath = "image_path"
        case tags
        case dateCreated = "date_created"
        case shared
    }

    func toDomain(ingredients: [UserIngredient]) -> UserRecipe {
        UserRecipe(
            id: UUID(),
            name: name,
            category: category,
            area: area,
            instructions: instructions,
            ingredients: ingredients,
            tags: Set(tags.compactMap { MealTag(rawValue: $0) }),
            imagePath: imagePath?.isEmpty == true ? nil : imagePath,
            dateCreated: Date(),
            dbId: id,
            shared: shared ?? false
        )
    }
}

struct UserRecipeInsert: Codable {
    let name: String
    let category: String
    let area: String
    let instructions: String
    let imagePath: String?
    let tags: [String]
    let shared: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case category
        case area
        case instructions
        case imagePath = "image_path"
        case tags
        case shared
    }

    static func from(domain: UserRecipe) -> UserRecipeInsert {
        UserRecipeInsert(
            name: domain.name,
            category: domain.category,
            area: domain.area,
            instructions: domain.instructions,
            imagePath: domain.imagePath,
            tags: domain.tags.map { $0.rawValue },
            shared: domain.shared
        )
    }
}

// user_ingredients: id (bigint auto), recipe_id (bigint FK), name, measure, sort_order, user_id

struct UserIngredientRow: Codable {
    let id: Int
    let recipeId: Int
    let name: String
    let measure: String
    let sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case name
        case measure
        case sortOrder = "sort_order"
    }

    func toDomain() -> UserIngredient {
        UserIngredient(name: name, measure: measure)
    }
}

struct UserIngredientInsert: Codable {
    let recipeId: Int
    let name: String
    let measure: String
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case recipeId = "recipe_id"
        case name
        case measure
        case sortOrder = "sort_order"
    }

    static func from(domain: UserIngredient, recipeId: Int, sortOrder: Int) -> UserIngredientInsert {
        UserIngredientInsert(
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
        let rows: [SavedRecipeRow] = try await client
            .from("saved_recipes")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    func insertSavedRecipe(_ recipe: SavedRecipe, userId: UUID) async throws {
        let insert = SavedRecipeInsert.from(domain: recipe)
        try await client
            .from("saved_recipes")
            .insert(insert)
            .execute()
    }

    func deleteSavedRecipe(mealId: String, userId: UUID) async throws {
        try await client
            .from("saved_recipes")
            .delete()
            .eq("recipe_id", value: mealId)
            .eq("user_id", value: userId)
            .execute()
    }

    func updateSavedRecipeTags(mealId: String, tags: Set<MealTag>, userId: UUID) async throws {
        try await client
            .from("saved_recipes")
            .update(["tags": tags.map { $0.rawValue }])
            .eq("recipe_id", value: mealId)
            .eq("user_id", value: userId)
            .execute()
    }
}

// MARK: - User Recipes CRUD

extension SupabaseService {

    func fetchUserRecipes(userId: UUID) async throws -> [UserRecipe] {
        let recipeRows: [UserRecipeRow] = try await client
            .from("user_recipes")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        guard !recipeRows.isEmpty else { return [] }

        let recipeIds = recipeRows.map { $0.id }
        let ingredientRows: [UserIngredientRow] = try await client
            .from("user_ingredients")
            .select()
            .in("recipe_id", values: recipeIds)
            .order("sort_order")
            .execute()
            .value

        let ingredientsByRecipe = Dictionary(grouping: ingredientRows) { $0.recipeId }

        return recipeRows.map { row in
            let ingredients = (ingredientsByRecipe[row.id] ?? []).map { $0.toDomain() }
            return row.toDomain(ingredients: ingredients)
        }
    }

    /// Inserts recipe and returns the auto-generated DB id
    func insertUserRecipe(_ recipe: UserRecipe, userId: UUID) async throws -> Int {
        let insert = UserRecipeInsert.from(domain: recipe)
        let inserted: [UserRecipeRow] = try await client
            .from("user_recipes")
            .insert(insert)
            .select()
            .execute()
            .value

        guard let dbId = inserted.first?.id else {
            throw NSError(domain: "SupabaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No id returned from insert"])
        }

        let ingredientInserts = recipe.ingredients
            .filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
            .enumerated()
            .map { index, ing in
                UserIngredientInsert.from(domain: ing, recipeId: dbId, sortOrder: index)
            }
        if !ingredientInserts.isEmpty {
            try await client
                .from("user_ingredients")
                .insert(ingredientInserts)
                .execute()
        }

        return dbId
    }

    func updateUserRecipe(_ recipe: UserRecipe, userId: UUID) async throws {
        guard let dbId = recipe.dbId else { return }
        let insert = UserRecipeInsert.from(domain: recipe)
        try await client
            .from("user_recipes")
            .update(insert)
            .eq("id", value: dbId)
            .eq("user_id", value: userId)
            .execute()

        // Replace ingredients: delete old, insert new
        try await client
            .from("user_ingredients")
            .delete()
            .eq("recipe_id", value: dbId)
            .execute()

        let ingredientInserts = recipe.ingredients
            .filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
            .enumerated()
            .map { index, ing in
                UserIngredientInsert.from(domain: ing, recipeId: dbId, sortOrder: index)
            }
        if !ingredientInserts.isEmpty {
            try await client
                .from("user_ingredients")
                .insert(ingredientInserts)
                .execute()
        }
    }

    func deleteUserRecipe(dbId: Int, userId: UUID) async throws {
        try await client
            .from("user_ingredients")
            .delete()
            .eq("recipe_id", value: dbId)
            .execute()

        try await client
            .from("user_recipes")
            .delete()
            .eq("id", value: dbId)
            .eq("user_id", value: userId)
            .execute()
    }

    func updateUserRecipeTags(dbId: Int, tags: Set<MealTag>, userId: UUID) async throws {
        try await client
            .from("user_recipes")
            .update(["tags": tags.map { $0.rawValue }])
            .eq("id", value: dbId)
            .eq("user_id", value: userId)
            .execute()
    }
}

// MARK: - Community (Shared) Recipes

extension SupabaseService {

    func fetchSharedRecipes() async throws -> [UserRecipe] {
        let recipeRows: [UserRecipeRow] = try await client
            .from("user_recipes")
            .select()
            .eq("shared", value: true)
            .execute()
            .value

        guard !recipeRows.isEmpty else { return [] }

        let recipeIds = recipeRows.map { $0.id }
        let ingredientRows: [UserIngredientRow] = try await client
            .from("user_ingredients")
            .select()
            .in("recipe_id", values: recipeIds)
            .order("sort_order")
            .execute()
            .value

        let ingredientsByRecipe = Dictionary(grouping: ingredientRows) { $0.recipeId }

        return recipeRows.map { row in
            let ingredients = (ingredientsByRecipe[row.id] ?? []).map { $0.toDomain() }
            return row.toDomain(ingredients: ingredients)
        }
    }

    func toggleShared(dbId: Int, shared: Bool, userId: UUID) async throws {
        try await client
            .from("user_recipes")
            .update(["shared": shared])
            .eq("id", value: dbId)
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
