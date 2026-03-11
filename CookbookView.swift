//
//  CookbookView.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import SwiftUI

struct CookbookView: View {
    @Environment(CookbookStore.self) private var store
    @State private var filterTag: MealTag?
    @State private var showAddRecipeSheet = false

    private var filteredRecipes: [SavedRecipe] {
        if let filterTag {
            return store.savedRecipes.filter { $0.tags.contains(filterTag) }
        }
        return store.savedRecipes
    }

    private var filteredUserRecipes: [UserRecipe] {
        if let filterTag {
            return store.userRecipes.filter { $0.tags.contains(filterTag) }
        }
        return store.userRecipes
    }

    private var hasAnyRecipes: Bool {
        !filteredRecipes.isEmpty || !filteredUserRecipes.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tagFilterBar

                if !hasAnyRecipes {
                    ContentUnavailableView(
                        filterTag != nil ? "No \(filterTag!.rawValue) Recipes" : "No Recipes Yet",
                        systemImage: filterTag != nil ? filterTag!.icon : "book.closed",
                        description: Text(filterTag != nil
                            ? "You haven't tagged any recipes as \(filterTag!.rawValue) yet."
                            : "Save recipes from any screen or create your own with the + button.")
                    )
                } else {
                    List {
                        if !filteredUserRecipes.isEmpty {
                            Section {
                                ForEach(filteredUserRecipes) { recipe in
                                    NavigationLink {
                                        UserRecipeDetailView(recipeId: recipe.id)
                                    } label: {
                                        userRecipeRow(recipe: recipe)
                                    }
                                }
                                .onDelete(perform: deleteUserRecipes)
                            } header: {
                                HStack {
                                    Text("My Recipes")
                                    Spacer()
                                    Text("\(filteredUserRecipes.count)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        if !filteredRecipes.isEmpty {
                            Section {
                                ForEach(filteredRecipes) { recipe in
                                    NavigationLink {
                                        RecipeDetailView(mealId: recipe.mealId)
                                    } label: {
                                        savedRecipeRow(recipe: recipe)
                                    }
                                }
                                .onDelete(perform: deleteRecipes)
                            } header: {
                                HStack {
                                    Text("Saved Recipes")
                                    Spacer()
                                    Text("\(filteredRecipes.count)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Cookbook")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAddRecipeSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if hasAnyRecipes {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showAddRecipeSheet) {
                AddRecipeView()
            }
        }
    }

    private var tagFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", tag: nil)
                ForEach(MealTag.allCases) { tag in
                    filterChip(label: tag.rawValue, tag: tag, icon: tag.icon)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
    }

    private func filterChip(label: String, tag: MealTag?, icon: String? = nil) -> some View {
        let isActive = filterTag == tag
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                filterTag = isActive ? nil : tag
            }
        } label: {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(label)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isActive ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(isActive ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func savedRecipeRow(recipe: SavedRecipe) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: recipe.thumbURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    Color.gray.opacity(0.1)
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.body.weight(.medium))
                    .lineLimit(2)

                HStack(spacing: 6) {
                    if let category = recipe.category {
                        Text(category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let area = recipe.area {
                        Text("· \(area)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if !recipe.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(recipe.tags).sorted(by: { $0.rawValue < $1.rawValue })) { tag in
                            Image(systemName: tag.icon)
                                .font(.caption2)
                                .foregroundStyle(tagColor(tag))
                        }
                    }
                }
            }

            Spacer()
        }
    }

    private func tagColor(_ tag: MealTag) -> Color {
        switch tag {
        case .dinner: return .orange
        case .quick: return .blue
        case .healthy: return .green
        }
    }

    private func userRecipeRow(recipe: UserRecipe) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange.opacity(0.15))
                Image(systemName: "fork.knife")
                    .font(.title3)
                    .foregroundStyle(.orange)
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.body.weight(.medium))
                    .lineLimit(2)

                HStack(spacing: 6) {
                    if !recipe.category.isEmpty {
                        Text(recipe.category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if !recipe.area.isEmpty {
                        Text("· \(recipe.area)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if !recipe.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(recipe.tags).sorted(by: { $0.rawValue < $1.rawValue })) { tag in
                            Image(systemName: tag.icon)
                                .font(.caption2)
                                .foregroundStyle(tagColor(tag))
                        }
                    }
                }
            }

            Spacer()
        }
    }

    private func deleteUserRecipes(at offsets: IndexSet) {
        let recipesToDelete = offsets.map { filteredUserRecipes[$0] }
        for recipe in recipesToDelete {
            store.removeUserRecipe(id: recipe.id)
        }
    }

    private func deleteRecipes(at offsets: IndexSet) {
        let recipesToDelete = offsets.map { filteredRecipes[$0] }
        for recipe in recipesToDelete {
            store.remove(mealId: recipe.mealId)
        }
    }
}
