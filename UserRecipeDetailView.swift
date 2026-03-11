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
                        tagsSection

                        // Ingredients
                        if !recipe.ingredients.isEmpty {
                            ingredientsSection(recipe: recipe)
                        }

                        // Instructions
                        if !recipe.instructions.isEmpty {
                            instructionsSection(instructions: recipe.instructions)
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

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Tags")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(MealTag.allCases) { tag in
                    let isActive = currentTags.contains(tag)
                    Button {
                        store.toggleUserRecipeTag(tag, for: recipeId)
                    } label: {
                        Label(tag.rawValue, systemImage: tag.icon)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isActive ? tagColor(tag).opacity(0.2) : Color.gray.opacity(0.1))
                            .foregroundStyle(isActive ? tagColor(tag) : .secondary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .strokeBorder(isActive ? tagColor(tag) : .clear, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func ingredientsSection(recipe: UserRecipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(Array(recipe.ingredients.enumerated()), id: \.element.id) { index, item in
                    HStack {
                        Text(item.name)
                            .font(.body)
                        Spacer()
                        Text(item.measure)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(index % 2 == 0 ? Color(.secondarySystemBackground) : Color.clear)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color(.separator), lineWidth: 0.5)
            )
        }
    }

    private func instructionsSection(instructions: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
                .font(.headline)

            Text(instructions)
                .font(.body)
                .lineSpacing(4)
        }
    }

    private func tagColor(_ tag: MealTag) -> Color {
        switch tag {
        case .dinner: return .orange
        case .quick: return .blue
        case .healthy: return .green
        }
    }
}
