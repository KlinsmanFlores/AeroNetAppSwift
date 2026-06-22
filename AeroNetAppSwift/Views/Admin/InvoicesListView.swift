import SwiftUI

struct InvoicesListView: View {
    @StateObject private var viewModel = InvoicesViewModel()
    @State private var showPeriodSheet = false
    @State private var selectedPeriod = ""
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            
            VStack {
                // Botones de acción masiva
                HStack(spacing: 12) {
                    Button(action: {
                        let today = Date()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM"
                        selectedPeriod = formatter.string(from: today)
                        showPeriodSheet = true
                    }) {
                        Label("Facturar Mes", systemName: "doc.badge.plus")
                            .font(.system(size: 13, weight: .bold))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color.theme.accent.opacity(0.15))
                            .foregroundColor(Color.theme.accent)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.theme.accent.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Button(action: {
                        Task {
                            _ = await viewModel.forceBillingInvoices()
                        }
                    }) {
                        Label("Forzar Proceso", systemName: "play.fill")
                            .font(.system(size: 13, weight: .bold))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color.theme.success.opacity(0.15))
                            .foregroundColor(Color.theme.success)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.theme.success.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                
                if let success = viewModel.successMessage {
                    Text(success)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.theme.success)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                }
                
                if viewModel.isLoading && viewModel.invoices.isEmpty {
                    ProgressView("Cargando facturas...")
                        .foregroundColor(.white)
                        .padding(.top, 40)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(iconName: "exclamationmark.triangle", title: "Error", message: error)
                } else if viewModel.invoices.isEmpty {
                    EmptyStateView(iconName: "doc.text", title: "Sin Comprobantes", message: "No hay facturas ni deudas emitidas en el sistema.")
                } else {
                    List {
                        ForEach(viewModel.invoices) { invoice in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(invoice.service?.customer?.full_name ?? "Cliente Desconocido")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    BadgeView(text: invoice.statusLabel, status: invoice.status ?? "pending")
                                }
                                
                                Text("Periodo: \(invoice.period ?? "N/A") | Vence: \(invoice.due_date ?? "Sin fecha")")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    if let address = invoice.service?.address_text {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Text((invoice.total ?? 0.0).currencyPEN)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.vertical, 6)
                            .listRowBackground(Color.theme.cardBackground.opacity(0.6))
                        }
                        .onDelete(perform: deleteInvoice)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
        }
        .navigationTitle("Facturación & Deudas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        await viewModel.fetchInvoices()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color.theme.accent)
                }
            }
        }
        .task {
            await viewModel.fetchInvoices()
        }
        .sheet(isPresented: $showPeriodSheet) {
            NavigationStack {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("Generar Facturas Mensuales")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Ingrese el periodo en formato AAAA-MM (Ej. 2026-06):")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        TextField("Periodo", text: $selectedPeriod)
                            .padding()
                            .background(Color.theme.surface)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                        
                        Button("Generar Ahora") {
                            Task {
                                let success = await viewModel.generateMonthlyInvoices(period: selectedPeriod)
                                if success {
                                    showPeriodSheet = false
                                }
                            }
                        }
                        .primaryButton()
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                    .padding(.top, 30)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancelar") {
                            showPeriodSheet = false
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .presentationDetents([.fraction(0.4)])
        }
    }
    
    private func deleteInvoice(at offsets: IndexSet) {
        for index in offsets {
            let invoice = viewModel.invoices[index]
            Task {
                _ = await viewModel.deleteInvoice(id: invoice.id)
            }
        }
    }
}

struct InvoicesListView_Previews: PreviewProvider {
    static var previews: some View {
        InvoicesListView()
    }
}
