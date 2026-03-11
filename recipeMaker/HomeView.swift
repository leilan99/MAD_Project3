//
//  HomeView.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import SwiftUI

struct HomeView: View {
    @State private var featuredMeals: [MealDTO] = []
    @State private var categories: [CategoryDTO] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 24) {
                    // Welcome quote
                    Text("Food always comes to those who love to cook.")
                        .font(.subheadline.weight(.bold))
                        .italic()
                        .foregroundStyle(Color.orange)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                    
                    // Categories
                    if !categories.isEmpty {
                        categoriesSection
                    }
                    
                    // Featured Recipes
                    if !featuredMeals.isEmpty {
                        featuredSection
                    }

                }
                .padding()
            }
            .navigationTitle("Welcome")
            .overlay {
                if isLoading {
                    ProgressView("Loading recipes...")
                }
                if let errorMessage {
                    ContentUnavailableView(
                        "Something went wrong",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                }
            }
            .task {
                await loadData()
            }
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured Recipes")
                    .font(.title2.weight(.bold))
                Spacer()
                Button("Refresh") {
                    Task { await loadFeatured() }
                }
                .font(.subheadline)
            }

            ForEach(featuredMeals, id: \.idMeal) { meal in
                NavigationLink(value: meal.idMeal) {
                    VStack(alignment: .leading, spacing: 12) {
                        AsyncImage(url: URL(string: meal.strMealThumb ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fill)
                            case .failure:
                                Color.gray.opacity(0.3)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .foregroundStyle(.secondary)
                                    }
                            default:
                                Color.gray.opacity(0.1)
                                    .overlay { ProgressView() }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                        .contentShape(Rectangle())

                        VStack(alignment: .leading, spacing: 6) {
                            Text(meal.strMeal)
                                .font(.headline)
                            HStack(spacing: 12) {
                                if let category = meal.strCategory {
                                    Label(category, systemImage: "tag.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                if let area = meal.strArea {
                                    Label(area, systemImage: "globe")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(14)
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
            }
            .navigationDestination(for: String.self) { mealId in
                RecipeDetailView(mealId: mealId)
            }
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.title2.weight(.bold))

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(categories) { category in
                        NavigationLink {
                            CategoryMealsView(categoryName: category.strCategory)
                        } label: {
                            Text(category.strCategory)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray5))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func loadData() async {
        guard featuredMeals.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            async let fetchedCategories = MealService.shared.fetchCategories()
            async let fetchedFeatured = fetchRandomMeals()
            categories = try await fetchedCategories
            featuredMeals = try await fetchedFeatured
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadFeatured() async {
        do {
            featuredMeals = try await fetchRandomMeals()
        } catch {
            // Keep the existing featured meals if refresh fails
        }
    }

    private func fetchRandomMeals() async throws -> [MealDTO] {
        try await withThrowingTaskGroup(of: MealDTO?.self) { group in
            for _ in 0..<3 {
                group.addTask {
                    try await MealService.shared.fetchRandomMeal()
                }
            }
            var meals: [MealDTO] = []
            for try await meal in group {
                if let meal { meals.append(meal) }
            }
            return meals
        }
    }
}

// MARK: - Category Meals List

struct CategoryMealsView: View {
    let categoryName: String
    @State private var meals: [MealSummaryDTO] = []
    @State private var isLoading = true

    var body: some View {
        List(meals) { meal in
            NavigationLink(value: meal.idMeal) {
                MealListRow(title: meal.strMeal, imageURL: meal.strMealThumb)
            }
        }
        .navigationTitle(categoryName)
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .navigationDestination(for: String.self) { mealId in
            RecipeDetailView(mealId: mealId)
        }
        .task {
            do {
                meals = try await MealService.shared.fetchMeals(forCategory: categoryName)
            } catch {}
            isLoading = false
        }
    }
}
