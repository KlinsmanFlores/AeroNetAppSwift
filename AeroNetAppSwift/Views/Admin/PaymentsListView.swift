import SwiftUI

struct PaymentsListView: View {
    @StateObject private var viewModel = PaymentsViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading && viewModel.payments.isEmpty {
                    ProgressView("Cargando historial de pagos...")
                        .foregroundColor(.black)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(iconName: "exclamationmark.triangle", title: "Error", message: error)
                } else if viewModel.payments.isEmpty {
                    EmptyStateView(iconName: "creditcard", title: "Sin Transacciones", message: "No se registran transacciones ni pagos procesados.")
                } else {
                    List {
                        ForEach(viewModel.payments) { payment in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(payment.transaction_reference ?? "Simulación de Pago")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.black)
                                        
                                        Text("Método: \(payment.payment_method?.uppercased() ?? "MÉTODO")")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.theme.textMuted)
                                    }
                                    Spacer()
                                    Text("+\((payment.amount_received ?? 0).currencyPEN)")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color.theme.success)
                                }
                                
                                Text("Fecha: \(payment.created_at ?? "Sin fecha")")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.theme.textMuted)
                            }
                            .padding(.vertical, 6)
                            .listRowBackground(Color.theme.cardBackground.opacity(0.6))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
        }
        .navigationTitle("Historial de Pagos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.fetchPayments()
                    
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color.theme.accent)
                }
            }
        }
        .onAppear {
            viewModel.fetchPayments()
        }
    }
}

struct PaymentsListView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsListView()
    }
}
