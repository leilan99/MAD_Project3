//
//  recipeMakerApp.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import SwiftUI
import Auth

@main
struct recipeMakerApp: App {
    @State private var cookbookStore = CookbookStore()
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoading {
                    ProgressView()
                } else if authViewModel.isAuthenticated {
                    ContentView()
                        .environment(cookbookStore)
                } else {
                    AuthView()
                }
            }
            .environment(authViewModel)
            .onChange(of: authViewModel.session) { _, newSession in
                if let user = newSession?.user {
                    cookbookStore.userId = user.id
                    Task {
                        try? await cookbookStore.migrateFromUserDefaultsIfNeeded()
                        try? await cookbookStore.loadAll()
                    }
                } else {
                    cookbookStore.userId = nil
                    cookbookStore.savedRecipes = []
                    cookbookStore.userRecipes = []
                }
            }
        }
    }
}
