import SwiftUI

struct ClientTabView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView {
            NavigationStack {
                ClientHomeView()
            }
            .tabItem {
                Label("Inicio", systemName: "house.fill")
            }
            
            NavigationStack {
                ClientDebtsView()
            }
            .tabItem {
                Label("Pagar", systemName: "creditcard.fill")
            }
            
            NavigationStack {
                ClientInvoicesView()
            }
            .tabItem {
                Label("Recibos", systemName: "doc.text.fill")
            }
            
            NavigationStack {
                ClientTicketsView()
            }
            .tabItem {
                Label("Soporte", systemName: "questionmark.circle.fill")
            }
            
            NavigationStack {
                ClientPlansView()
            }
            .tabItem {
                Label("Planes", systemName: "wifi.circle.fill")
            }
            
            NavigationStack {
                ClientProfileView()
            }
            .tabItem {
                Label("Perfil", systemName: "person.fill")
            }
        }
        .accentColor(Color.theme.accent)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.theme.backgroundGradientBottom)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct ClientTabView_Previews: PreviewProvider {
    static var previews: some View {
        ClientTabView()
            .environmentObject(AuthManager())
    }
}
