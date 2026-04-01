//
//  MealSummaryDTO.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import Foundation

struct MealSummaryDTO: Codable, Identifiable, Sendable {
    var id: String { idMeal }
    let idMeal: String
    let strMeal: String
    let strMealThumb: String?
}

struct MealSummaryResponse: Codable, Sendable {
    let meals: [MealSummaryDTO]?
}
