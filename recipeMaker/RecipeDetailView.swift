//
//  RecipeDetailView.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import SwiftUI

struct RecipeDetailView: View {
    let mealId: String
    @Environment(CookbookStore.self) private var store
    @State private var meal: MealDTO?
    @State private var isLoading = true

    private var isSaved: Bool {
        store.isSaved(mealId: mealId)
    }

    private var currentTags: Set<MealTag> {
        store.tags(for: mealId)
    }

    var body: some View {
        ScrollView {
            if let meal {
                VStack(alignment: .leading, spacing: 0) {
                    headerImage(meal: meal)
                    content(meal: meal)
                }
            }
        }
        .navigationTitle(meal?.strMeal ?? "Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let meal {
                    Button {
                        store.toggleSaved(meal: meal)
                    } label: {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .foregroundStyle(isSaved ? .red : .secondary)
                    }
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .task {
            do {
                meal = try await MealService.shared.fetchMealDetail(id: mealId)
            } catch {}
            isLoading = false
        }
    }

    private func headerImage(meal: MealDTO) -> some View {
        AsyncImage(url: URL(string: meal.strMealThumb ?? "")) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure:
                Color.gray.opacity(0.3)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            default:
                Color.gray.opacity(0.1)
                    .overlay { ProgressView() }
            }
        }
        .frame(height: 280)
        .clipped()
    }

    private func content(meal: MealDTO) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title & Meta
            VStack(alignment: .leading, spacing: 8) {
                Text(meal.strMeal)
                    .font(.title2.weight(.bold))

                HStack(spacing: 16) {
                    if let category = meal.strCategory {
                        Label(category, systemImage: "tag.fill")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                    }
                    if let area = meal.strArea {
                        Label(area, systemImage: "globe")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                }
            }

            // Tags (if saved)
            if isSaved {
                tagsSection
            }

            // Video
            if let youtubeURL = meal.strYoutube, !youtubeURL.isEmpty,
               let url = URL(string: youtubeURL) {
                videoSection(url: url)
            }

            // Ingredients
            ingredientsSection(meal: meal)

            // Instructions
            if let instructions = meal.strInstructions, !instructions.isEmpty {
                instructionsSection(instructions: instructions)
            }
        }
        .padding()
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Tags")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(MealTag.allCases) { tag in
                    let isActive = currentTags.contains(tag)
                    Button {
                        store.toggleTag(tag, for: mealId)
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

    private func tagColor(_ tag: MealTag) -> Color {
        switch tag {
        case .dinner: return .orange
        case .quick: return .blue
        case .healthy: return .green
        }
    }

    private func videoSection(url: URL) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Video")
                .font(.headline)

            Link(destination: url) {
                HStack {
                    Image(systemName: "play.rectangle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                    Text("Watch on YouTube")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
    }

    private func ingredientsSection(meal: MealDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(Array(meal.ingredients.enumerated()), id: \.offset) { index, item in
                    HStack {
                        Text(item.ingredient)
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
}
