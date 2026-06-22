import SwiftUI

struct ClientInvoicesView: View {
    @StateObject private var viewModel = ClientInvoicesViewModel()
    @State private var selectedInvoice: Invoice? = nil
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading && viewModel.invoices.isEmpty {
                    ProgressView("Buscando comprobantes...")
                        .foregroundColor(.white)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(iconName: "exclamationmark.triangle", title: "Error", message: error)
                } else if viewModel.invoices.isEmpty {
                    EmptyStateView(iconName: "doc.text", title: "Sin Comprobantes", message: "No tienes recibos emitidos en el sistema.")
                } else {
                    List {
                        ForEach(viewModel.invoices) { invoice in
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Recibo Periodo: \(invoice.period ?? "N/A")")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Vencimiento: \(invoice.due_date ?? "Sin fecha")")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 6) {
                                    Text((invoice.total ?? 0.0).currencyPEN)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    BadgeView(text: invoice.statusLabel, status: invoice.status ?? "pending")
                                }
                            }
                            .padding(.vertical, 6)
                            .listRowBackground(Color.theme.cardBackground.opacity(0.6))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Al pulsar abre el PDF/Recibo usando UIKit WKWebView (Semana 10)
                                if let link = invoice.payment_link, !link.isEmpty {
                                    selectedInvoice = invoice
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
        }
        .navigationTitle("Mis Recibos")
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
        .sheet(item: $selectedInvoice) { invoice in
            NavigationStack {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    
                    if let link = invoice.payment_link, let url = URL(string: link) {
                        // WKWebView integrado con UIViewRepresentable (Semana 10)
                        WebViewRepresentable(url: url)
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        EmptyStateView(iconName: "doc.text.fill", title: "Sin Enlace", message: "Este recibo no tiene un PDF de pago disponible.")
                    }
                }
                .navigationTitle("Detalle de Recibo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cerrar") {
                            selectedInvoice = nil
                        }
                        .foregroundColor(Color.theme.accent)
                    }
                }
            }
        }
    }
}

struct ClientInvoicesView_Previews: PreviewProvider {
    static var previews: some View {
        ClientInvoicesView()
    }
}
