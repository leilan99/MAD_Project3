//
//  IngredientDTO.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import Foundation

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
