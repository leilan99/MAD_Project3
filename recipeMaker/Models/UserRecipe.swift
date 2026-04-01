//
//  UserRecipe.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import Foundation

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
