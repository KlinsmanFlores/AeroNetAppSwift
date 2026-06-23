import SwiftUI

struct ServicesListView: View {
    @StateObject private var viewModel = ServicesViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading && viewModel.services.isEmpty {
                    ProgressView("Cargando servicios...")
                        .foregroundColor(.white)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(iconName: "exclamationmark.triangle", title: "Error", message: error)
                } else if viewModel.services.isEmpty {
                    EmptyStateView(iconName: "network", title: "Sin Servicios", message: "No hay conexiones ni servicios registrados en el sistema.")
                } else {
                    List {
                        ForEach(viewModel.services) { service in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(service.customer?.full_name ?? "Cliente Desconocido")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    BadgeView(text: service.statusLabel, status: service.status ?? "pending")
                                }
                                
                                Text(service.address_text ?? "Dirección sin registrar")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Label(
                                        "Plan: \(service.plan?.name ?? "N/A") (\(Int(service.plan?.speed_mbps ?? 0)) Mbps)", systemImage: "wifi"
                                    )
                                    .font(.caption)
                                    .foregroundColor(Color.theme.accent)
                                    
                                    Spacer()
                                    
                                    Text("Día de Pago: \(service.billing_day ?? 1)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color.theme.cardBackground.opacity(0.6))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
        }
        .navigationTitle("Conexiones de Red")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.fetchServices()
                    
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color.theme.accent)
                }
            }
        }
        .onAppear {
            viewModel.fetchServices()
        }
    }
}

struct ServicesListView_Previews: PreviewProvider {
    static var previews: some View {
        ServicesListView()
    }
}
