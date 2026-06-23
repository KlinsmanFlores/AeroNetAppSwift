import SwiftUI

struct ClientTicketsView: View {
    @StateObject private var viewModel = ClientTicketsViewModel()
    @State private var showCreateSheet = false
    @State private var newSubject = ""
    @State private var newDescription = ""
    @State private var selectedPriority = "medium"
    @State private var selectedType = "support" // support or technical
    @State private var selectedServiceId = ""
    @State private var myServicesList: [ServiceModel] = []
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading && viewModel.tickets.isEmpty {
                    ProgressView("Cargando tickets...")
                        .foregroundColor(.white)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(iconName: "exclamationmark.triangle", title: "Error", message: error)
                } else if viewModel.tickets.isEmpty {
                    EmptyStateView(
                        iconName: "lifepreserver",
                        title: "Sin Tickets",
                        message: "¿Tienes algún inconveniente? Crea un ticket de soporte y te ayudaremos."
                    )
                } else {
                    ticketsList
                        .transition(.opacity)
                }
            }
            .animation(.spring(), value: viewModel.tickets.count)
        }
        .navigationTitle("Soporte Técnico")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.fetchTickets()
                        
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color.theme.accent)
                    }
                    
                    Button(action: {
                        showCreateSheet = true
                        ServiceService.shared.fetchMyServices { result in
                            DispatchQueue.main.async {
                                if case .success(let services) = result {
                                    myServicesList = services
                                    if let first = services.first {
                                        selectedServiceId = first.id
                                    }
                                }
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color.theme.accent)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchTickets()
        }
        .sheet(isPresented: $showCreateSheet) {
            NavigationView {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    
                    Form {
                        Section(header: Text("Servicio Afectado").foregroundColor(.gray)) {
                            Picker("Servicio", selection: $selectedServiceId) {
                                Text("Ninguno / General").tag("")
                                ForEach(myServicesList) { srv in
                                    Text(srv.plan?.name ?? srv.address_text ?? "Servicio").tag(srv.id)
                                }
                            }
                            .foregroundColor(.white)
                        }
                        .listRowBackground(Color.theme.surface)
                        
                        Section(header: Text("Detalles de Solicitud").foregroundColor(.gray)) {
                            Picker("Tipo de Ticket", selection: $selectedType) {
                                Text("Soporte Técnico").tag("technical")
                                Text("Administrativo / Facturación").tag("administrative")
                                Text("General").tag("support")
                            }
                            .foregroundColor(.white)
                            
                            Picker("Prioridad", selection: $selectedPriority) {
                                Text("Baja").tag("low")
                                Text("Media").tag("medium")
                                Text("Alta").tag("high")
                            }
                            .foregroundColor(.white)
                            
                            TextField("Asunto", text: $newSubject)
                                .foregroundColor(.white)
                            
                            TextField("Descripción del problema", text: $newDescription)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.theme.surface)
                    }
                    .background(Color.clear)
                }
                .navigationTitle("Nuevo Ticket")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancelar") {
                            showCreateSheet = false
                            clearFields()
                        }
                        .foregroundColor(.red)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Enviar") {
                                let serviceIdParam: String? = selectedServiceId.isEmpty ? nil : selectedServiceId
                                viewModel.createTicket(
                                    serviceId: serviceIdParam,
                                    type: selectedType,
                                    subject: newSubject,
                                    description: newDescription,
                                    priority: selectedPriority,
                                    category: selectedType
                                ) { success in
                                    if success {
                                        showCreateSheet = false
                                        clearFields()
                                    }
                                }
                        }
                        .foregroundColor(Color.theme.accent)
                    }
                }
            }
        }
    }
    
    private var ticketsList: some View {
        List {
            ForEach(viewModel.tickets) { ticket in
                ticketRow(ticket)
                    .padding(.vertical, 6)
                    .listRowBackground(Color.theme.cardBackground.opacity(0.6))
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
    
    private func ticketRow(_ ticket: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ticket.subject ?? "Sin Asunto")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                BadgeView(text: ticket.statusLabel, status: ticket.status ?? "open")
            }
            
            Text(ticket.description ?? "Sin descripción")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Label("Prioridad: \(ticket.priorityLabel)", systemImage: "flag.fill")
                    .font(.caption)
                    .foregroundColor(priorityColor(ticket.priority))
                
                Spacer()
                
                if let dateStr = ticket.created_at {
                    Text(dateStr)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private func priorityColor(_ priority: String?) -> Color {
        switch priority?.lowercased() {
        case "low": return .green
        case "medium": return .yellow
        case "high": return .red
        default: return .gray
        }
    }
    
    private func clearFields() {
        newSubject = ""
        newDescription = ""
        selectedPriority = "medium"
        selectedType = "support"
        selectedServiceId = ""
    }
}

struct ClientTicketsView_Previews: PreviewProvider {
    static var previews: some View {
        ClientTicketsView()
    }
}
