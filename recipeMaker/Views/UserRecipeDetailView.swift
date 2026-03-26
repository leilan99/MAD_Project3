//
//  UserRecipeDetailView.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/10/26.
//

import SwiftUI

struct UserRecipeDetailView: View {
    let recipeId: UUID
    @Environment(CookbookStore.self) private var store
    @State private var showEditSheet = false

    private var recipe: UserRecipe? {
        store.userRecipes.first { $0.id == recipeId }
    }

    private var currentTags: Set<MealTag> {
        store.userRecipeTags(for: recipeId)
    }

    var body: some View {
        ScrollView {
            if let recipe {
                VStack(alignment: .leading, spacing: 0) {
                    // Placeholder header
                    ZStack {
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.orange.opacity(0.5))
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

                            Label("My Recipe", systemImage: "person.fill")
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.15))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }

                        // Tags
                        VStack(alignment: .leading, spacing: 8) {
                            Text("My Tags")
                                .font(.headline)
                            TagChipBar(tags: currentTags) { tag in
                                store.toggleUserRecipeTag(tag, for: recipeId)
                            }
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
        }
        .navigationTitle(recipe?.name ?? "Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let recipe {
                AddRecipeView(existingRecipe: recipe)
            }
        }
    }

}
