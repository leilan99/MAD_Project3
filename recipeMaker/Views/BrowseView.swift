//
//  BrowseView.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import SwiftUI

struct BrowseView: View {
    @State private var areas: [AreaDTO] = []
    @State private var ingredients: [IngredientDTO] = []
    @State private var searchText = ""
    @State private var searchResults: [MealDTO] = []
    @State private var isSearching = false
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            List {
                if !searchResults.isEmpty {
                    searchResultsSection
                } else if searchText.isEmpty {
                    cuisinesSection
                    ingredientsSection
                }
            }
            .navigationTitle("Browse")
            .searchable(text: $searchText, prompt: "Search recipes...")
            .onSubmit(of: .search) {
                Task { await performSearch() }
            }
            .onChange(of: searchText) { _, newValue in
                if newValue.isEmpty {
                    searchResults = []
                }
            }
            .overlay {
                if isLoading && searchText.isEmpty {
                    ProgressView()
                }
                if isSearching {
                    ProgressView("Searching...")
                }
            }
            .task {
                await loadBrowseData()
            }
        }
    }

    private var cuisinesSection: some View {
        Section("Cuisines") {
            ForEach(areas) { area in
                NavigationLink {
                    FilteredMealsView(title: area.strArea) {
                        try await MealService.shared.fetchMeals(forArea: area.strArea)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "globe")
                            .font(.title3)
                            .foregroundStyle(.orange)
                            .frame(width: 32)
                        Text(area.strArea)
                    }
                }
            }
        }
    }

    private var ingredientsSection: some View {
        Section("Popular Ingredients") {
            ForEach(ingredients.prefix(50)) { ingredient in
                NavigationLink {
                    FilteredMealsView(title: ingredient.strIngredient) {
                        try await MealService.shared.fetchMeals(forIngredient: ingredient.strIngredient)
                    }
                } label: {
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: ingredient.thumbURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fit)
                            default:
                                Color.gray.opacity(0.1)
                            }
                        }
                        .frame(width: 36, height: 36)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                        Text(ingredient.strIngredient)
                    }
                }
            }
        }
    }

    private var searchResultsSection: some View {
        Section("Search Results") {
            ForEach(searchResults) { meal in
                NavigationLink {
                    RecipeDetailView(mealId: meal.idMeal)
                } label: {
                    MealListRow(
                        title: meal.strMeal,
                        imageURL: meal.strMealThumb,
                        subtitle: [meal.strCategory, meal.strArea]
                            .compactMap { $0 }
                            .joined(separator: " · ")
                    )
                }
            }
        }
    }

    private func loadBrowseData() async {
        do {
            async let fetchedAreas = MealService.shared.fetchAreas()
            async let fetchedIngredients = MealService.shared.fetchIngredients()
            areas = try await fetchedAreas
            ingredients = try await fetchedIngredients
        } catch {}
        isLoading = false
    }

    private func performSearch() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        do {
            searchResults = try await MealService.shared.searchMeals(query: searchText)
        } catch {}
        isSearching = false
    }
}

