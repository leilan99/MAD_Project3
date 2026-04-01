//
//  AuthViewModel.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/25/26.
//

import Foundation
import Supabase

@Observable
final class AuthViewModel {
    var session: Session?
    var isLoading = true
    var errorMessage: String?

    var isAuthenticated: Bool { session != nil }
    var userId: UUID? { session?.user.id }

    private let client = SupabaseService.shared.client

    init() {
        Task {
            for await (event, session) in client.auth.authStateChanges {
                if [.initialSession, .signedIn, .signedOut, .tokenRefreshed].contains(event) {
                    await MainActor.run {
                        self.session = session
                        self.isLoading = false
                    }
                }
            }
        }
    }

    // MARK: - Email/Password Auth

    func signUp(email: String, password: String) async {
        do {
            errorMessage = nil
            try await client.auth.signUp(email: email, password: password)
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }

    func signIn(email: String, password: String) async {
        do {
            errorMessage = nil
            try await client.auth.signIn(email: email, password: password)
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }

    func signOut() async {
        try? await client.auth.signOut()
    }
}
