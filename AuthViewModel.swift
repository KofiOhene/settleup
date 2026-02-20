import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    func checkSession() async {
        do {
            let session = try await AppSupabase.client.auth.session
            isLoggedIn = true
        } catch {
            isLoggedIn = false
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await AppSupabase.client.auth.signIn(email: email, password: password)
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await AppSupabase.client.auth.signUp(email: email, password: password)
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signInWithGoogle() async {
        // TODO: Implement Google sign-in
    }

    func signInWithApple() async {
        // TODO: Implement Apple sign-in
    }

    func signOut() async {
        do {
            try await AppSupabase.client.auth.signOut()
            isLoggedIn = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
