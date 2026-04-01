//
//  AddRecipeView.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import PhotosUI
import SwiftUI

struct AddRecipeView: View {
    @Environment(CookbookStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var existingRecipe: UserRecipe?

    @State private var name = ""
    @State private var category = ""
    @State private var area = ""
    @State private var instructions = ""
    @State private var ingredients: [UserIngredient] = [UserIngredient()]
    @State private var selectedTags: Set<MealTag> = []
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        ingredients.contains { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe Info") {
                    TextField("Recipe Name", text: $name)
                    TextField("Category (e.g. Dessert)", text: $category)
                    TextField("Cuisine (e.g. Italian)", text: $area)
                }

                Section("Photo") {
                    if let imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }

                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label(
                            imageData != nil ? "Change Photo" : "Add Photo",
                            systemImage: imageData != nil ? "photo.badge.arrow.down" : "photo.badge.plus"
                        )
                    }
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                imageData = data
                            }
                        }
                    }

                    if imageData != nil {
                        Button(role: .destructive) {
                            imageData = nil
                            selectedPhoto = nil
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    }
                }

                Section {
                    ForEach($ingredients) { $ingredient in
                        HStack {
                            TextField("Ingredient", text: $ingredient.name)
                            TextField("Amount", text: $ingredient.measure)
                                .frame(maxWidth: 120)
                        }
                    }
                    .onDelete(perform: deleteIngredient)

                    Button {
                        ingredients.append(UserIngredient())
                    } label: {
                        Label("Add Ingredient", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Ingredients")
                } footer: {
                    Text("Add at least one ingredient.")
                }

                Section("Instructions") {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 120)
                }

                Section("Tags") {
                    TagChipBar(tags: selectedTags) { tag in
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    }
                }
            }
            .navigationTitle(existingRecipe != nil ? "Edit Recipe" : "New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await saveRecipe() }
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let existingRecipe {
                    name = existingRecipe.name
                    category = existingRecipe.category
                    area = existingRecipe.area
                    instructions = existingRecipe.instructions
                    ingredients = existingRecipe.ingredients
                    selectedTags = existingRecipe.tags
                    if let path = existingRecipe.imagePath,
                       let uiImage = store.loadImage(path: path) {
                        imageData = uiImage.jpegData(compressionQuality: 1.0)
                    }
                }
            }
        }
    }

    private func saveRecipe() async {
        let cleanedIngredients = ingredients.filter {
            !$0.name.trimmingCharacters(in: .whitespaces).isEmpty
        }

        if let existingRecipe {
            var updated = existingRecipe
            updated.name = name.trimmingCharacters(in: .whitespaces)
            updated.category = category.trimmingCharacters(in: .whitespaces)
            updated.area = area.trimmingCharacters(in: .whitespaces)
            updated.instructions = instructions
            updated.ingredients = cleanedIngredients
            updated.tags = selectedTags

            // Handle image changes
            if let imageData {
                if let oldPath = existingRecipe.imagePath {
                    try? await store.deleteStorageImage(path: oldPath)
                }
                updated.imagePath = try? await store.saveImage(imageData, for: existingRecipe.id)
            } else if existingRecipe.imagePath != nil {
                try? await store.deleteStorageImage(path: existingRecipe.imagePath!)
                updated.imagePath = nil
            }

            try? await store.updateUserRecipe(updated)
        } else {
            let recipeId = UUID()
            var imagePath: String?
            if let imageData {
                imagePath = try? await store.saveImage(imageData, for: recipeId)
            }
            let recipe = UserRecipe(
                id: recipeId,
                name: name.trimmingCharacters(in: .whitespaces),
                category: category.trimmingCharacters(in: .whitespaces),
                area: area.trimmingCharacters(in: .whitespaces),
                instructions: instructions,
                ingredients: cleanedIngredients,
                tags: selectedTags,
                imagePath: imagePath
            )
            try? await store.addUserRecipe(recipe)
        }
        dismiss()
    }

    private func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
        if ingredients.isEmpty {
            ingredients.append(UserIngredient())
        }
    }

}
