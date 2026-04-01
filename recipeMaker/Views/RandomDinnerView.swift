//
//  RandomDinnerView.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import SwiftUI

struct RandomDinnerView: View {
    @Environment(CookbookStore.self) private var store
    @State private var meal: MealDTO?
    @State private var isSpinning = false
    @State private var showResult = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 20)

                    // Slot machine / spinner visual
                    VStack(spacing: 16) {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.orange)
                            .rotationEffect(.degrees(rotationAngle))
                            .symbolEffect(.bounce, value: isSpinning)

                        Text("What's for dinner?")
                            .font(.title.weight(.bold))

                        Text("Can't decide? Let fate choose your next meal!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    // Spin button
                    Button {
                        Task { await generateRandom() }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "shuffle")
                            Text(meal == nil ? "Generate Random Dinner" : "Spin Again!")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .orange.opacity(0.4), radius: 8, y: 4)
                    }
                    .disabled(isSpinning)

                    // Result card
                    if let meal, showResult {
                        resultCard(meal: meal)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Random Dinner")
            .animation(.spring(duration: 0.5), value: showResult)
        }
    }

    private func resultCard(meal: MealDTO) -> some View {
        VStack(spacing: 0) {
            NavigationLink {
                RecipeDetailView(mealId: meal.idMeal)
            } label: {
                VStack(spacing: 0) {
                    AsyncImage(url: URL(string: meal.strMealThumb ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            Color.gray.opacity(0.1)
                                .overlay { ProgressView() }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .contentShape(Rectangle())

                    VStack(alignment: .leading, spacing: 8) {
                        Text(meal.strMeal)
                            .font(.headline)
                            .multilineTextAlignment(.leading)

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

                        HStack {
                            Text("Tap to view full recipe")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Spacer()
                        }
                    }
                    .padding(14)
                }
            }
            .buttonStyle(.plain)

            // Save button outside of NavigationLink so taps don't conflict
            HStack {
                Spacer()
                Button {
                    Task { try? await store.toggleSaved(meal: meal) }
                } label: {
                    Image(systemName: store.isSaved(mealId: meal.idMeal) ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(store.isSaved(mealId: meal.idMeal) ? .red : .secondary)
                        .padding(10)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
        .padding(.horizontal)
    }

    private func generateRandom() async {
        isSpinning = true
        showResult = false

        // Animate the dice
        withAnimation(.easeInOut(duration: 1.0)) {
            rotationAngle += 720
        }

        // Small delay for dramatic effect
        try? await Task.sleep(for: .seconds(0.8))

        do {
            meal = try await MealService.shared.fetchRandomMeal()
        } catch {}

        withAnimation {
            showResult = true
        }
        isSpinning = false
    }
}
