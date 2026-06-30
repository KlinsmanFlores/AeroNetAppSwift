import SwiftUI

struct ClientDebtsView: View {
    @StateObject private var viewModel = ClientDebtsViewModel()
    @State private var showingConfetti = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading && viewModel.pendingInvoices.isEmpty {
                    ProgressView("Buscando deudas...")
                        .foregroundColor(.black)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(iconName: "exclamationmark.triangle", title: "Error", message: error)
                } else if viewModel.pendingInvoices.isEmpty {
                    EmptyStateView(
                        iconName: "checkmark.circle.fill",
                        title: "¡Estás al día!",
                        message: "No tienes facturas pendientes de pago en este momento."
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Resumen Total
                            GlassCard {
                                VStack(spacing: 8) {
                                    Text("TOTAL PENDIENTE")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color.theme.textSecondary)
                                    
                                    Text(viewModel.totalPendingDebt.currencyPEN)
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(Color.theme.textPrimary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            
                            // Lista de Recibos por Pagar
                            VStack(alignment: .leading, spacing: 12) {
                                Text("DEUDAS PENDIENTES")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color.theme.textSecondary)
                                    .padding(.horizontal, 20)
                                
                                ForEach(viewModel.pendingInvoices) { invoice in
                                    GlassCard {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text("Recibo Periodo: \(invoice.period ?? "N/A")")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.black)
                                                
                                                Text("Vence: \(invoice.due_date ?? "Sin fecha")")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(Color.theme.danger)
                                                
                                                Text("Monto: \((invoice.total ?? 0).currencyPEN)")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.black)
                                            }
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                viewModel.payInvoice(id: invoice.id) { success in
                                                    if success {
                                                        showingConfetti = true
                                                        // Ocultar confetti después de 4 segundos
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                                                            showingConfetti = false
                                                        }
                                                    }
                                                }
                                            }) {
                                                if viewModel.isPaying {
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.background))
                                                } else {
                                                    Text("Pagar")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .padding(.horizontal, 16)
                                                        .padding(.vertical, 8)
                                                        .background(Color.theme.accent)
                                                        .foregroundColor(Color.theme.background)
                                                        .cornerRadius(8)
                                                }
                                            }
                                            .buttonStyle(ScaleButtonStyle())
                                            .disabled(viewModel.isPaying)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                }
            }
            
            // Animación de Confetti de Éxito de Pago (Semana 14)
            if showingConfetti {
                AnimatedConfetti()
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .navigationTitle("Pagar Servicios")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.fetchDebts()
                    
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color.theme.accent)
                }
            }
        }
        .onAppear {
            viewModel.fetchDebts()
        }
    }
}

struct ClientDebtsView_Previews: PreviewProvider {
    static var previews: some View {
        ClientDebtsView()
    }
}
