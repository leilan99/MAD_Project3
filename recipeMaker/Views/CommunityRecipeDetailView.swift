//
//  CommunityRecipeDetailView.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/25/26.
//

import SwiftUI

struct CommunityRecipeDetailView: View {
    let recipe: UserRecipe
    @Environment(CookbookStore.self) private var store
    @State private var saved = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                ZStack {
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "person.2.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)

                VStack(alignment: .leading, spacing: 20) {
                    // Title & Meta
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.name)
                            .font(.title2.weight(.bold))

                        HStack(spacing: 16) {
                            if !recipe.category.isEmpty {
                                Label(recipe.category, systemImage: "tag.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.orange)
                            }
                            if !recipe.area.isEmpty {
                                Label(recipe.area, systemImage: "globe")
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                            }
                        }

                        Label("Community Recipe", systemImage: "person.2.fill")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.15))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }

                    // Ingredients
                    if !recipe.ingredients.isEmpty {
                        IngredientsSection(items: recipe.ingredients.map { ($0.name, $0.measure) })
                    }

                    // Instructions
                    if !recipe.instructions.isEmpty {
                        InstructionsSection(instructions: recipe.instructions)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        try? await store.saveAsCopy(recipe)
                        saved = true
                    }
                } label: {
                    Image(systemName: saved ? "checkmark" : "square.and.arrow.down")
                        .foregroundStyle(saved ? .green : .orange)
                }
                .disabled(saved)
            }
        }
    }
}
