import SwiftUI

struct InvoicesListView: View {
    @StateObject private var viewModel = InvoicesViewModel()
    @State private var showPeriodSheet = false
    @State private var selectedPeriod = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Botones de acción masiva
                actionButtons
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
                        .foregroundColor(.black)
                        .padding(.top, 40)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(iconName: "exclamationmark.triangle", title: "Error", message: error)
                } else if viewModel.invoices.isEmpty {
                    EmptyStateView(iconName: "doc.text", title: "Sin Comprobantes", message: "No hay facturas ni deudas emitidas en el sistema.")
                } else {
                    invoicesList
                }
            }
        }
        .navigationTitle("Facturación & Deudas")
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
        .sheet(isPresented: $showPeriodSheet) {
            NavigationView {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("Generar Facturas Mensuales")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text("Ingrese el periodo en formato AAAA-MM (Ej. 2026-06):")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        TextField("Periodo", text: $selectedPeriod)
                            .padding()
                            .background(Color.theme.surface)
                            .cornerRadius(12)
                            .foregroundColor(.black)
                            .padding(.horizontal, 30)
                        
                        Button("Generar") {
                            viewModel.generateMonthlyInvoices(period: selectedPeriod) { success in
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
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: {
                let today = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM"
                selectedPeriod = formatter.string(from: today)
                showPeriodSheet = true
            }) {
                Label("Facturar Mes", systemImage: "doc.badge.plus")
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
                viewModel.forceBillingInvoices { _ in }
            }) {
                Label("Forzar Proceso", systemImage: "play.fill")
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
    }
    
    private var invoicesList: some View {
        List {
            ForEach(viewModel.invoices) { invoice in
                invoiceRow(invoice)
                    .padding(.vertical, 6)
                    .listRowBackground(Color.theme.cardBackground.opacity(0.6))
            }
            .onDelete(perform: deleteInvoice)
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
    
    private func invoiceRow(_ invoice: Invoice) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(invoice.service?.customer?.full_name ?? "Cliente Desconocido")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                BadgeView(text: invoice.statusLabel, status: invoice.status ?? "pending")
            }
            
            Text("Periodo: \(invoice.period ?? "N/A") | Vence: \(invoice.due_date ?? "Sin fecha")")
                .font(.system(size: 12))
                .foregroundColor(Color.theme.textMuted)
            
            HStack {
                if let address = invoice.service?.address_text {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(Color.theme.textMuted)
                        .lineLimit(1)
                }
                Spacer()
                Text((invoice.total ?? 0.0).currencyPEN)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
            
            if let doc = viewModel.electronicDocuments[invoice.id] {
                Divider().background(Color.white.opacity(0.15))
                
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
                        .foregroundColor(.black)
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
                                    .foregroundColor(Color.theme.textMuted)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 4)
            }
        }
    }
    
    private func deleteInvoice(at offsets: IndexSet) {
        for index in offsets {
            let invoice = viewModel.invoices[index]
            viewModel.deleteInvoice(id: invoice.id) { _ in }
        }
    }
}

struct InvoicesListView_Previews: PreviewProvider {
    static var previews: some View {
        InvoicesListView()
    }
}
