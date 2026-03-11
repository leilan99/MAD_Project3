//
//  HomeView.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import SwiftUI

struct HomeView: View {
    @State private var featuredMeal: MealDTO?
    @State private var categories: [CategoryDTO] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Featured Recipe
                    if let meal = featuredMeal {
                        featuredSection(meal: meal)
                    }

                    // Categories
                    if !categories.isEmpty {
                        categoriesSection
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
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

    private func featuredSection(meal: MealDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured Recipe")
                    .font(.title2.weight(.bold))
                Spacer()
                Button("Refresh") {
                    Task { await loadFeatured() }
                }
                .font(.subheadline)
            }

            NavigationLink(value: meal.idMeal) {
                VStack(alignment: .leading, spacing: 0) {
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
            .navigationDestination(for: String.self) { mealId in
                RecipeDetailView(mealId: mealId)
            }
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.title2.weight(.bold))

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(categories) { category in
                    NavigationLink {
                        CategoryMealsView(categoryName: category.strCategory)
                    } label: {
                        RecipeCard(
                            title: category.strCategory,
                            imageURL: category.strCategoryThumb
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let fetchedCategories = MealService.shared.fetchCategories()
            async let fetchedFeatured = MealService.shared.fetchRandomMeal()
            categories = try await fetchedCategories
            featuredMeal = try await fetchedFeatured
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadFeatured() async {
        do {
            featuredMeal = try await MealService.shared.fetchRandomMeal()
        } catch {
            // Keep the existing featured meal if refresh fails
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
