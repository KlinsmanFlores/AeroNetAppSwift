import SwiftUI

struct ClientInvoicesView: View {
    @StateObject private var viewModel = ClientInvoicesViewModel()
    @State private var selectedTab: InvoiceFilter = .pending
    
    enum InvoiceFilter: String, CaseIterable, Identifiable {
        case pending = "Pendientes"
        case billed = "Facturados"
        
        var id: String { self.rawValue }
    }
    
    private var filteredInvoices: [Invoice] {
        switch selectedTab {
        case .pending:
            return viewModel.invoices.filter { ($0.status ?? "").lowercased() == "pending" }
        case .billed:
            return viewModel.invoices.filter {
                let stat = ($0.status ?? "").lowercased()
                return stat == "paid" || stat == "invoiced"
            }
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Picker("Filtro", selection: $selectedTab) {
                    ForEach(InvoiceFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 8)
                
                if viewModel.isLoading && viewModel.invoices.isEmpty {
                    Spacer()
                    ProgressView("Buscando comprobantes...")
                        .foregroundColor(.white)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(iconName: "exclamationmark.triangle", title: "Error", message: error)
                } else if filteredInvoices.isEmpty {
                    Spacer()
                    EmptyStateView(
                        iconName: selectedTab == .pending ? "creditcard" : "doc.text",
                        title: selectedTab == .pending ? "Todo al día" : "Sin Historial",
                        message: selectedTab == .pending ? "No tienes recibos pendientes de pago." : "No se encontraron comprobantes facturados."
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(filteredInvoices) { invoice in
                            InvoiceRowView(invoice: invoice, viewModel: viewModel, currentTab: selectedTab)
                                .listRowBackground(Color.theme.cardBackground.opacity(0.6))
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
                    viewModel.fetchInvoices()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color.theme.accent)
                }
            }
        }
        .onAppear {
            viewModel.fetchInvoices()
        }
        .sheet(isPresented: $viewModel.showDocViewer) {
            NavigationView {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    
                    if let url = viewModel.activeWebUrl {
                        WebViewRepresentable(url: url)
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        EmptyStateView(iconName: "doc.text.fill", title: "Error", message: "No se pudo recuperar el enlace de Nubefact.")
                    }
                }
                .navigationTitle(viewModel.activeDocTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cerrar") {
                            viewModel.showDocViewer = false
                        }
                        .foregroundColor(Color.theme.accent)
                    }
                }
            }
        }
    }
}

// MARK: - COMPONENTE DE FILA PROTEGIDO CONTRA ERRORES DE BASE DE DATOS
struct InvoiceRowView: View {
    let invoice: Invoice
    @ObservedObject var viewModel: ClientInvoicesViewModel
    let currentTab: ClientInvoicesView.InvoiceFilter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
            
            Divider().background(Color.white.opacity(0.15))
            
            actionsView
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private var actionsView: some View {
        // 🚀 SALVADO TÉCNICO: Si de casualidad el backend ya vinculó un documento electrónico,
        // mostramos la boleta sin importar en qué pestaña se encuentre parado.
        if let doc = viewModel.electronicDocuments[invoice.id] {
            VStack(spacing: 8) {
                Button(action: {
                    if let pdfUrlString = doc.pdf_url, let url = URL(string: pdfUrlString) {
                        viewModel.activeWebUrl = url
                        viewModel.activeDocTitle = "\(doc.type ?? "COMPROBANTE") \(doc.series ?? "")-\(doc.number ?? 0)"
                        viewModel.showDocViewer = true
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                        Text("Ver \(doc.type == "FACTURA" ? "Factura" : "Boleta") Digital")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color.blue.opacity(0.35))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                
                if let xmlStr = doc.xml_url, !xmlStr.isEmpty {
                    Button(action: {
                        viewModel.abrirEnNavegador(urlString: xmlStr)
                    }) {
                        HStack {
                            Image(systemName: "arrow.down.doc.fill")
                            Text("Descargar XML Tributario (SUNAT)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        } else if currentTab == .billed {
            // --- PESTAÑA: FACTURADOS (Sin documento encontrado) ---
            HStack {
                if viewModel.isLoading {
                    ProgressView().scaleEffect(0.7)
                    Text("Buscando comprobante...")
                        .font(.caption2)
                        .foregroundColor(.gray)
                } else {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("Comprobante electrónico no disponible en SUNAT")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 4)
            
        } else {
            // --- PESTAÑA: PENDIENTES (Sin documento y con link de pasarela) ---
            if let link = invoice.payment_link, !link.isEmpty, let url = URL(string: link) {
                Button(action: {
                    viewModel.activeWebUrl = url
                    viewModel.activeDocTitle = "Pasarela de Pago Online"
                    viewModel.showDocViewer = true
                }) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text("Pagar Recibo")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle()) // 🚀 Adiós definitivo al recuadro blanco roto
            } else {
                HStack {
                    Image(systemName: "clock.fill").font(.caption)
                    Text("Enlace de pago en proceso de generación...")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 4)
            }
        }
    }
}
