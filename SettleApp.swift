import SwiftUI

@main
struct SettleApp: App {
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if authVM.isLoggedIn {
                    DashboardView()
                } else {
                    WelcomeView()
                }
            }
            .environmentObject(authVM)
            .task {
                await authVM.checkSession()
            }
        }
    }
}
