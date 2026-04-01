//
//  Models.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import Foundation
import SwiftUI

// MARK: - API Response Models

struct MealsResponse: Codable, Sendable {
    let meals: [MealDTO]?
}

struct CategoriesResponse: Codable, Sendable {
    let categories: [CategoryDTO]
}

struct CategoryDTO: Codable, Identifiable, Sendable {
    var id: String { idCategory }
    let idCategory: String
    let strCategory: String
    let strCategoryThumb: String
    let strCategoryDescription: String
}

struct MealDTO: Codable, Identifiable, Sendable {
    var id: String { idMeal }
    let idMeal: String
    let strMeal: String
    let strMealAlternate: String?
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?
    let strTags: String?
    let strYoutube: String?
    let strSource: String?

    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?
    let strIngredient16: String?
    let strIngredient17: String?
    let strIngredient18: String?
    let strIngredient19: String?
    let strIngredient20: String?

    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?
    let strMeasure16: String?
    let strMeasure17: String?
    let strMeasure18: String?
    let strMeasure19: String?
    let strMeasure20: String?

    var ingredients: [(ingredient: String, measure: String)] {
        let allIngredients = [
            strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,
            strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10,
            strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15,
            strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        ]
        let allMeasures = [
            strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5,
            strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10,
            strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15,
            strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
        ]
        var result: [(ingredient: String, measure: String)] = []
        for i in 0..<20 {
            if let ingredient = allIngredients[i],
               !ingredient.trimmingCharacters(in: .whitespaces).isEmpty {
                let measure = allMeasures[i]?.trimmingCharacters(in: .whitespaces) ?? ""
                result.append((ingredient: ingredient, measure: measure))
            }
        }
        return result
    }
}

struct AreaDTO: Codable, Identifiable, Sendable {
    var id: String { strArea }
    let strArea: String
}

struct AreaListResponse: Codable, Sendable {
    let meals: [AreaDTO]
}

struct IngredientDTO: Codable, Identifiable, Sendable {
    var id: String { idIngredient }
    let idIngredient: String
    let strIngredient: String
    let strDescription: String?
    let strType: String?

    var thumbURL: String {
        "https://www.themealdb.com/images/ingredients/\(strIngredient)-Small.png"
    }
}

struct IngredientListResponse: Codable, Sendable {
    let meals: [IngredientDTO]
}

// MARK: - Meal Summary (for list views from filter/search endpoints)

struct MealSummaryDTO: Codable, Identifiable, Sendable {
    var id: String { idMeal }
    let idMeal: String
    let strMeal: String
    let strMealThumb: String?
}

struct MealSummaryResponse: Codable, Sendable {
    let meals: [MealSummaryDTO]?
}

// MARK: - User Tag

enum MealTag: String, Codable, CaseIterable, Identifiable {
    case dinner = "Dinner"
    case quick = "Quick"
    case healthy = "Healthy"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dinner: return "fork.knife"
        case .quick: return "bolt.fill"
        case .healthy: return "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .dinner: return .orange
        case .quick: return .blue
        case .healthy: return .green
        }
    }
}

// MARK: - Saved Recipe (for persistence)

struct SavedRecipe: Codable, Identifiable {
    var id: String { mealId }
    let mealId: String
    let name: String
    let thumbURL: String?
    let category: String?
    let area: String?
    var tags: Set<MealTag>
    let dateSaved: Date
}

// MARK: - User-Created Recipe

struct UserIngredient: Codable, Identifiable {
    let id: UUID
    var name: String
    var measure: String

    init(id: UUID = UUID(), name: String = "", measure: String = "") {
        self.id = id
        self.name = name
        self.measure = measure
    }
}

struct UserRecipe: Codable, Identifiable {
    let id: UUID
    var name: String
    var category: String
    var area: String
    var instructions: String
    var ingredients: [UserIngredient]
    var tags: Set<MealTag>
    var imagePath: String?
    let dateCreated: Date
    var dbId: Int?
    var shared: Bool

    init(
        id: UUID = UUID(),
        name: String = "",
        category: String = "",
        area: String = "",
        instructions: String = "",
        ingredients: [UserIngredient] = [UserIngredient()],
        tags: Set<MealTag> = [],
        imagePath: String? = nil,
        dateCreated: Date = Date(),
        dbId: Int? = nil,
        shared: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.area = area
        self.instructions = instructions
        self.ingredients = ingredients
        self.tags = tags
        self.imagePath = imagePath
        self.dateCreated = dateCreated
        self.dbId = dbId
        self.shared = shared
    }
}
