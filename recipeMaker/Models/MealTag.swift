//
//  MealTag.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import SwiftUI

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
