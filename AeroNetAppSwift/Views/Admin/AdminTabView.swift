import SwiftUI

struct AdminTabView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView {
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.xaxis")
            }
            
            NavigationView {
                CustomersListView()
            }
            .tabItem {
                Label("Clientes", systemImage: "person.3.fill")
            }
            
            NavigationView {
                PlansListView()
            }
            .tabItem {
                Label("Planes", systemImage: "wifi.circle.fill")
            }
            
            NavigationView {
                ServicesListView()
            }
            .tabItem {
                Label("Servicios", systemImage: "network")
            }
            
            NavigationView {
                InvoicesListView()
            }
            .tabItem {
                Label("Facturas", systemImage: "doc.text.fill")
            }
            
            NavigationView {
                PaymentsListView()
            }
            .tabItem {
                Label("Pagos", systemImage: "creditcard.fill")
            }
            
            NavigationView {
                TicketsListView()
            }
            .tabItem {
                Label("Tickets", systemImage: "lifepreserver.fill")
            }
            
            NavigationView {
                TechniciansListView()
            }
            .tabItem {
                Label("Técnicos", systemImage: "wrench.and.screwdriver.fill")
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
