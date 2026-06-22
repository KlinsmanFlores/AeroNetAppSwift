import SwiftUI

struct AdminTabView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemName: "chart.bar.xaxis")
            }
            
            NavigationStack {
                CustomersListView()
            }
            .tabItem {
                Label("Clientes", systemName: "person.3.fill")
            }
            
            NavigationStack {
                PlansListView()
            }
            .tabItem {
                Label("Planes", systemName: "wifi.circle.fill")
            }
            
            NavigationStack {
                ServicesListView()
            }
            .tabItem {
                Label("Servicios", systemName: "network")
            }
            
            NavigationStack {
                InvoicesListView()
            }
            .tabItem {
                Label("Facturas", systemName: "doc.text.fill")
            }
            
            NavigationStack {
                PaymentsListView()
            }
            .tabItem {
                Label("Pagos", systemName: "creditcard.fill")
            }
            
            NavigationStack {
                TicketsListView()
            }
            .tabItem {
                Label("Tickets", systemName: "lifepreserver.fill")
            }
            
            NavigationStack {
                TechniciansListView()
            }
            .tabItem {
                Label("Técnicos", systemName: "wrench.and.screwdriver.fill")
            }
        }
        .accentColor(Color.theme.accent)
        .onAppear {
            // Personalización de la barra de tabs para modo oscuro
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.theme.backgroundGradientBottom)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct AdminTabView_Previews: PreviewProvider {
    static var previews: some View {
        AdminTabView()
            .environmentObject(AuthManager())
    }
}
