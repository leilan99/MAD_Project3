//
//  Components.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import SwiftUI

// MARK: - Tag Chip Bar

struct TagChipBar: View {
    let tags: Set<MealTag>
    let onToggle: (MealTag) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(MealTag.allCases) { tag in
                let isActive = tags.contains(tag)
                Button {
                    onToggle(tag)
                } label: {
                    Label(tag.rawValue, systemImage: tag.icon)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isActive ? tag.color.opacity(0.2) : Color.gray.opacity(0.1))
                        .foregroundStyle(isActive ? tag.color : .secondary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(isActive ? tag.color : .clear, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Ingredients Section

struct IngredientsSection: View {
    let items: [(name: String, measure: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
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
}

// MARK: - Instructions Section

struct InstructionsSection: View {
    let instructions: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
                .font(.headline)

            Text(instructions)
                .font(.body)
                .lineSpacing(4)
        }
    }
}

// MARK: - Filtered Meals List

struct FilteredMealsView: View {
    let title: String
    let fetch: () async throws -> [MealSummaryDTO]
    @State private var meals: [MealSummaryDTO] = []
    @State private var isLoading = true

    var body: some View {
        List(meals) { meal in
            NavigationLink {
                RecipeDetailView(mealId: meal.idMeal)
            } label: {
                MealListRow(title: meal.strMeal, imageURL: meal.strMealThumb)
            }
        }
        .navigationTitle(title)
        .overlay {
            if isLoading { ProgressView() }
            if !isLoading && meals.isEmpty {
                ContentUnavailableView("No Recipes", systemImage: "fork.knife", description: Text("No recipes found for \(title)."))
            }
        }
        .task {
            do {
                meals = try await fetch()
            } catch {}
            isLoading = false
        }
    }
}

// MARK: - Recipe Card

struct RecipeCard: View {
    let title: String
    let imageURL: String?
    let subtitle: String?

    init(title: String, imageURL: String?, subtitle: String? = nil) {
        self.title = title
        self.imageURL = imageURL
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Color.gray.opacity(0.3)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                default:
                    Color.gray.opacity(0.1)
                        .overlay {
                            ProgressView()
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color(.secondarySystemBackground))
            .clipped()
            .contentShape(Rectangle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 44)
        }
        .frame(height: 164)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

struct MealListRow: View {
    let title: String
    let imageURL: String?
    let subtitle: String?

    init(title: String, imageURL: String?, subtitle: String? = nil) {
        self.title = title
        self.imageURL = imageURL
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Color.gray.opacity(0.3)
                default:
                    Color.gray.opacity(0.1)
                        .overlay { ProgressView() }
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .lineLimit(2)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }
}
