import SwiftUI

struct ClientTabView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView {
            NavigationView {
                ClientHomeView()
            }
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }
            
            NavigationView {
                ClientDebtsView()
            }
            .tabItem {
                Label("Pagar", systemImage: "creditcard.fill")
            }
            
            NavigationView {
                ClientInvoicesView()
            }
            .tabItem {
                Label("Recibos", systemImage: "doc.text.fill")
            }
            
            NavigationView {
                ClientTicketsView()
            }
            .tabItem {
                Label("Soporte", systemImage: "questionmark.circle.fill")
            }
            
            NavigationView {
                ClientPlansView()
            }
            .tabItem {
                Label("Planes", systemImage: "wifi.circle.fill")
            }
            
            NavigationView {
                ClientProfileView()
            }
            .tabItem {
                Label("Perfil", systemImage: "person.fill")
            }
        }
        .accentColor(Color.theme.accent)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.theme.backgroundGradientBottom)
            UITabBar.appearance().standardAppearance = appearance
        }
    }
}

struct ClientTabView_Previews: PreviewProvider {
    static var previews: some View {
        ClientTabView()
            .environmentObject(AuthManager())
    }
}
