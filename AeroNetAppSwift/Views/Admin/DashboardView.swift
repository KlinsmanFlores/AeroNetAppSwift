import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = DashboardViewModel()
    
    // 🚀 RESPONSIVO: Configuramos una grilla automática de 2 columnas flexibles
    private let columnasGrid = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Cabecera con Logout
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AeroNet Admin")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(Color.theme.textPrimary)
                            
                            Text("Panel de Control General")
                                .font(.system(size: 14))
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            authManager.logout()
                        }) {
                            Image(systemName: "power")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.theme.danger)
                                .frame(width: 44, height: 44)
                                .background(Color.theme.surface)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    if viewModel.isLoading {
                        // Skeleton load placeholders (Semana 14)
                        VStack(spacing: 16) {
                            LazyVGrid(columns: columnasGrid, spacing: 16) {
                                ShimmerView(height: 90)
                                ShimmerView(height: 90)
                                ShimmerView(height: 90)
                                ShimmerView(height: 90)
                            }
                            ShimmerView(height: 200)
                        }
                        .padding(.horizontal, 20)
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Text(error)
                                .foregroundColor(Color.theme.danger)
                                .multilineTextAlignment(.center)
                            
                            Button("Reintentar") {
                                viewModel.loadDashboardData()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.theme.accent)
                            .foregroundColor(Color.theme.background)
                            .cornerRadius(10)
                        }
                        .padding(.vertical, 40)
                    } else {
                        // 🚀 SOLUCIÓN AL DESCUADRE: Reemplazamos los HStack rígidos por un LazyVGrid
                        LazyVGrid(columns: columnasGrid, spacing: 16) {
                            StatCard(title: "Clientes", value: "\(viewModel.totalCustomers)", iconName: "person.3.fill", iconColor: .blue)
                            
                            StatCard(title: "Servicios Activos", value: "\(viewModel.totalActiveServices)", iconName: "network", iconColor: Color.theme.success)
                            
                            StatCard(title: "Tickets Abiertos", value: "\(viewModel.totalPendingTickets)", iconName: "exclamationmark.bubble.fill", iconColor: Color.theme.warning)
                            
                            StatCard(title: "Deuda Pendiente", value: viewModel.totalOutstandingAmount.currencyPEN, iconName: "creditcard.fill", iconColor: Color.theme.danger)
                        }
                        .padding(.horizontal, 20)
                        
                        // Lista de Pagos Recientes
                        VStack(alignment: .leading, spacing: 14) {
                            Text("PAGOS RECIENTES")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.theme.textSecondary)
                                .padding(.horizontal, 20)
                            
                            if viewModel.recentPayments.isEmpty {
                                GlassCard {
                                    Text("No hay pagos recientes registrados.")
                                        .foregroundColor(Color.theme.textSecondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 20)
                                }
                                .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(viewModel.recentPayments) { payment in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(payment.transaction_reference ?? "Simulación de Pago")
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundColor(Color.theme.textPrimary)
                                                
                                                // 🎨 CORRECCIÓN DE COLOR GRIS: Forzamos textMuted con la nueva opacidad alta
                                                Text(payment.payment_method?.uppercased() ?? "MÉTODO")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(Color.theme.textMuted) // Antes se perdía, ahora resalta impecable
                                            }
                                            
                                            Spacer()
                                            
                                            Text("+\( (payment.amount_received ?? 0).currencyPEN )")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Color.theme.success)
                                        }
                                        .padding()
                                        .glassCard()
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            viewModel.loadDashboardData()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthManager())
    }
}
