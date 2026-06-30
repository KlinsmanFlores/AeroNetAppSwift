import SwiftUI

@main
struct AeroNetAppSwiftApp: App {
    @StateObject private var authManager = AuthManager()
    @State private var showSplash = true
    
    // 🚀 INYECCIÓN TRANSPARENTE: Obliga a las Navigation Bars a respetar el fondo en cualquier scroll
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // Adiós al bloque blanco molesto
        appearance.backgroundColor = .clear
        
        // Mantenemos las letras de los títulos siempre legibles en color blanco
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        // 🚀 Eliminar fondo blanco/gris de Listas y Tablas globalmente para ver el gradiente celeste
        UITableView.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear
    }
    
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
    }
}

// Helper para delay animado
extension DispatchQueue {
    func gradientDelay(seconds: Double, completion: @escaping () -> Void) {
        asyncAfter(deadline: .now() + seconds, execute: completion)
    }
}
