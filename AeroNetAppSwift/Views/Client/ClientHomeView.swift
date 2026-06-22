import SwiftUI

struct ClientHomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = ClientHomeViewModel()
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hola,")
                                .font(.system(size: 15))
                                .foregroundColor(Color.theme.textSecondary)
                            
                            Text(viewModel.customer?.full_name ?? authManager.currentUser?.email ?? "Usuario")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color.theme.textPrimary)
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
                        VStack(spacing: 16) {
                            ShimmerView(height: 120)
                            ShimmerView(height: 160)
                        }
                        .padding(.horizontal, 20)
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Text(error)
                                .foregroundColor(Color.theme.danger)
                                .multilineTextAlignment(.center)
                            
                            Button("Reintentar") {
                                Task {
                                    await viewModel.loadDashboard()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.theme.accent)
                            .foregroundColor(Color.theme.background)
                            .cornerRadius(10)
                        }
                        .padding(.vertical, 40)
                    } else {
                        // Resumen de Deudas (Semana 9)
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: "creditcard.fill")
                                        .foregroundColor(Color.theme.accent)
                                    Text("SALDO PENDIENTE")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                
                                HStack {
                                    Text(viewModel.totalPendingDebt.currencyPEN)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(Color.theme.textPrimary)
                                    
                                    Spacer()
                                    
                                    if viewModel.totalPendingDebt > 0 {
                                        BadgeView(text: "Pendiente", status: "pending")
                                    } else {
                                        BadgeView(text: "Al Día", status: "active")
                                    }
                                }
                                
                                if viewModel.totalPendingDebt > 0 {
                                    Text("Tienes facturas pendientes de pago. Por favor regulariza tu servicio para evitar suspensiones.")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.theme.textSecondary)
                                } else {
                                    Text("¡Gracias por mantenerte al día! Disfruta de la mejor velocidad.")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Mis Servicios / Conexiones
                        VStack(alignment: .leading, spacing: 14) {
                            Text("MIS CONEXIONES Y SERVICIOS")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.theme.textSecondary)
                                .padding(.horizontal, 20)
                            
                            if viewModel.myServices.isEmpty {
                                GlassCard {
                                    VStack(spacing: 12) {
                                        Image(systemName: "wifi.slash")
                                            .font(.system(size: 30))
                                            .foregroundColor(Color.theme.textSecondary)
                                        
                                        Text("No tienes servicios activos.")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color.theme.textPrimary)
                                        
                                        Text("Solicita una conexión en la pestaña de Planes.")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.theme.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                }
                                .padding(.horizontal, 20)
                            } else {
                                ForEach(viewModel.myServices) { service in
                                    GlassCard {
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(service.plan?.name ?? "Plan Contratado")
                                                        .font(.system(size: 17, weight: .bold))
                                                        .foregroundColor(.white)
                                                    
                                                    Text("\(Int(service.plan?.speed_mbps ?? 0)) Mbps")
                                                        .font(.system(size: 13, weight: .semibold))
                                                        .foregroundColor(Color.theme.accent)
                                                }
                                                
                                                Spacer()
                                                
                                                BadgeView(text: service.statusLabel, status: service.status ?? "pending")
                                            }
                                            
                                            Divider()
                                                .background(Color.theme.cardBorder)
                                            
                                            VStack(alignment: .leading, spacing: 6) {
                                                Label(service.address_text ?? "Sin dirección", systemName: "mappin.and.ellipse")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color.theme.textSecondary)
                                                
                                                Label("Día de facturación: \(service.billing_day ?? 1)", systemName: "calendar")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color.theme.textSecondary)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .task {
            await viewModel.loadDashboard()
        }
        .refreshable {
            await viewModel.loadDashboard()
        }
    }
}

struct ClientHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ClientHomeView()
            .environmentObject(AuthManager())
    }
}
