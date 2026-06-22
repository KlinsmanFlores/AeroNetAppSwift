import SwiftUI
import SwiftData

@main
struct AeroNetAppSwiftApp: App {
    @StateObject private var authManager = AuthManager()
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                } else {
                    Group {
                        if !authManager.isLoggedIn {
                            LoginView()
                        } else if authManager.isAdmin {
                            AdminTabView()
                        } else {
                            ClientTabView()
                        }
                    }
                    .transition(.opacity)
                }
            }
            .environmentObject(authManager)
            .onAppear {
                // Mantener el splash por 2 segundos para ver las animaciones
                DispatchQueue.main.gradientDelay(seconds: 2.2) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
        .modelContainer(for: [CachedPlan.self])
    }
}

// Helper para delay animado
extension DispatchQueue {
    func gradientDelay(seconds: Double, completion: @escaping () -> Void) {
        asyncAfter(deadline: .now() + seconds, execute: completion)
    }
}
