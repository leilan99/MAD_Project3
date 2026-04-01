//
//  AreaDTO.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import Foundation

struct AreaDTO: Codable, Identifiable, Sendable {
    var id: String { strArea }
    let strArea: String
}

struct AreaListResponse: Codable, Sendable {
    let meals: [AreaDTO]
}
