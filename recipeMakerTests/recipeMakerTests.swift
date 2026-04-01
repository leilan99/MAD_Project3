//
//  recipeMakerTests.swift
//  recipeMakerTests
//
//  Created by Leila Nunez on 3/9/26.
//

import Foundation
import Testing
@testable import recipeMaker

// MARK: - Test Helpers

/// Creates a fresh CookbookStore with no persisted data.
private func makeCleanStore() -> CookbookStore {
    UserDefaults.standard.removeObject(forKey: "savedRecipes")
    UserDefaults.standard.removeObject(forKey: "userRecipes")
    return CookbookStore()
}

/// Creates a MealDTO with the given id/name and optional ingredients for testing.
private func makeMealDTO(
    id: String = "1",
    name: String = "Test Meal",
    category: String? = "Dessert",
    area: String? = "Italian",
    ingredient1: String? = nil,
    measure1: String? = nil,
    ingredient2: String? = nil,
    measure2: String? = nil,
    ingredient3: String? = nil,
    measure3: String? = nil
) -> MealDTO {
    MealDTO(
        idMeal: id,
        strMeal: name,
        strMealAlternate: nil,
        strCategory: category,
        strArea: area,
        strInstructions: "Test instructions",
        strMealThumb: nil,
        strTags: nil,
        strYoutube: nil,
        strSource: nil,
        strIngredient1: ingredient1, strIngredient2: ingredient2, strIngredient3: ingredient3,
        strIngredient4: nil, strIngredient5: nil, strIngredient6: nil, strIngredient7: nil,
        strIngredient8: nil, strIngredient9: nil, strIngredient10: nil, strIngredient11: nil,
        strIngredient12: nil, strIngredient13: nil, strIngredient14: nil, strIngredient15: nil,
        strIngredient16: nil, strIngredient17: nil, strIngredient18: nil, strIngredient19: nil,
        strIngredient20: nil,
        strMeasure1: measure1, strMeasure2: measure2, strMeasure3: measure3,
        strMeasure4: nil, strMeasure5: nil, strMeasure6: nil, strMeasure7: nil,
        strMeasure8: nil, strMeasure9: nil, strMeasure10: nil, strMeasure11: nil,
        strMeasure12: nil, strMeasure13: nil, strMeasure14: nil, strMeasure15: nil,
        strMeasure16: nil, strMeasure17: nil, strMeasure18: nil, strMeasure19: nil,
        strMeasure20: nil
    )
}

// MARK: - CookbookStore Tests

@Suite(.serialized)
struct CookbookStoreTests {

    // MARK: Save/Unsave

    @Test func saveMeal() {
        let store = makeCleanStore()
        let meal = makeMealDTO(id: "100", name: "Pasta")

        store.save(meal: meal)

        #expect(store.savedRecipes.count == 1)
        #expect(store.savedRecipes.first?.mealId == "100")
        #expect(store.savedRecipes.first?.name == "Pasta")
    }

    @Test func duplicateSaveIsIgnored() {
        let store = makeCleanStore()
        let meal = makeMealDTO(id: "100", name: "Pasta")

        store.save(meal: meal)
        store.save(meal: meal)

        #expect(store.savedRecipes.count == 1)
    }

    @Test func isSavedReturnsCorrectly() {
        let store = makeCleanStore()
        let meal = makeMealDTO(id: "100", name: "Pasta")

        #expect(!store.isSaved(mealId: "100"))

        store.save(meal: meal)

        #expect(store.isSaved(mealId: "100"))
        #expect(!store.isSaved(mealId: "999"))
    }

    @Test func toggleSavedAddsAndRemoves() {
        let store = makeCleanStore()
        let meal = makeMealDTO(id: "100", name: "Pasta")

        store.toggleSaved(meal: meal)
        #expect(store.isSaved(mealId: "100"))

        store.toggleSaved(meal: meal)
        #expect(!store.isSaved(mealId: "100"))
        #expect(store.savedRecipes.isEmpty)
    }

    // MARK: Tags

    @Test func toggleTagOnSavedRecipe() {
        let store = makeCleanStore()
        let meal = makeMealDTO(id: "100", name: "Pasta")
        store.save(meal: meal)

        store.toggleTag(.dinner, for: "100")
        #expect(store.tags(for: "100").contains(.dinner))

        store.toggleTag(.dinner, for: "100")
        #expect(!store.tags(for: "100").contains(.dinner))
    }

    @Test func tagsForUnsavedRecipeReturnsEmpty() {
        let store = makeCleanStore()

        #expect(store.tags(for: "nonexistent").isEmpty)
    }
}

// MARK: - MealDTO Ingredient Parsing Tests

struct MealDTOTests {

    @Test func ingredientsParsing() {
        let meal = makeMealDTO(
            ingredient1: "Flour", measure1: "2 cups",
            ingredient2: "Sugar", measure2: "1 cup",
            ingredient3: nil, measure3: nil
        )

        let ingredients = meal.ingredients
        #expect(ingredients.count == 2)
        #expect(ingredients[0].ingredient == "Flour")
        #expect(ingredients[0].measure == "2 cups")
        #expect(ingredients[1].ingredient == "Sugar")
        #expect(ingredients[1].measure == "1 cup")
    }

    @Test func ingredientsSkipsEmptyStrings() {
        let meal = makeMealDTO(
            ingredient1: "Flour", measure1: "2 cups",
            ingredient2: "  ", measure2: "1 cup",
            ingredient3: "Eggs", measure3: "3"
        )

        let ingredients = meal.ingredients
        #expect(ingredients.count == 2)
        #expect(ingredients[0].ingredient == "Flour")
        #expect(ingredients[1].ingredient == "Eggs")
    }

    @Test func ingredientsEmptyWhenNoneProvided() {
        let meal = makeMealDTO()
        #expect(meal.ingredients.isEmpty)
    }
}
