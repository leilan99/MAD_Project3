//
//  CategoryDTO.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import Foundation

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
