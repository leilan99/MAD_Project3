//
//  SavedRecipe.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import Foundation

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
