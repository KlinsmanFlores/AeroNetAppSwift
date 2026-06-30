import SwiftUI

struct ClientTicketsView: View {
    @StateObject private var viewModel = ClientTicketsViewModel()
    @State private var showCreateSheet = false
    @State private var newSubject = ""
    @State private var newDescription = ""
    @State private var selectedPriority = "medium"
    @State private var selectedCategory = "RECLAMO"
    @State private var selectedServiceId = ""
    @State private var myServicesList: [ServiceModel] = []
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
               	 if viewModel.isLoading && viewModel.tickets.isEmpty {
                    ProgressView("Cargando tickets...")
                        .foregroundColor(.black)
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
                        Section(header: Text("Servicio Afectado").foregroundColor(Color.theme.textMuted)) {
                            Picker("Servicio", selection: $selectedServiceId) {
                                Text("Ninguno / General").tag("")
                                ForEach(myServicesList) { srv in
                                    Text(srv.plan?.name ?? srv.address_text ?? "Servicio").tag(srv.id)
                                }
                            }
                            .foregroundColor(.black)
                        }
                        .listRowBackground(Color.white)
                        
                        Section(header: Text("Detalles de Solicitud").foregroundColor(Color.theme.textMuted)) {
                            Picker("Categoría del Problema", selection: $selectedCategory) {
                                Text("Reclamo o Avería").tag("RECLAMO")
                                Text("Problemas de Cobertura Wi-Fi").tag("COBERTURA_WIFI")
                                Text("Traslado de Domicilio").tag("TRASLADO")
                                Text("Mejorar mi Plan").tag("MEJORA_PLAN")
                                Text("Pausar por Vacaciones").tag("PAUSA_VACACIONES")
                            }
                            .foregroundColor(.black)
                            
                            Picker("Prioridad", selection: $selectedPriority) {
                                Text("Baja").tag("low")
                                Text("Media").tag("medium")
                                Text("Alta").tag("high")
                            }
                            .foregroundColor(.black)
                            
                            TextField("Asunto", text: $newSubject)
                                .foregroundColor(.black)
                            
                            TextField("Descripción del problema", text: $newDescription)
                                .foregroundColor(.black)
                        }
                        .listRowBackground(Color.white)
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
                                    type: "ticket",
                                    subject: newSubject,
                                    description: newDescription,
                                    priority: selectedPriority,
                                    category: selectedCategory
                                ) { success in
                                    if success {
                                        showCreateSheet = false
                                        clearFields()
                                    }
                                }
                        }
                        .foregroundColor(newSubject.isEmpty || newDescription.isEmpty ? .gray : Color.theme.accent)
                        .disabled(newSubject.isEmpty || newDescription.isEmpty)
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
                    .foregroundColor(.black)
                Spacer()
                BadgeView(text: ticket.statusLabel, status: ticket.status ?? "open")
            }
            
            Text(translateCategory(ticket.category))
                .font(.system(size: 11, weight: .semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.theme.accent.opacity(0.2))
                .foregroundColor(Color.theme.accent)
                .cornerRadius(4)
            
            Text(ticket.description ?? "Sin descripción")
                .font(.system(size: 13))
                .foregroundColor(Color.theme.textMuted)
                .lineLimit(2)
            
            HStack {
                Label("Prioridad: \(ticket.priorityLabel)", systemImage: "flag.fill")
                    .font(.caption)
                    .foregroundColor(priorityColor(ticket.priority))
                
                Spacer()
                
                if let dateStr = ticket.created_at {
                    Text(dateStr)
                        .font(.caption)
                        .foregroundColor(Color.theme.textMuted)
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
    
    private func translateCategory(_ cat: String?) -> String {
        switch cat {
        case "RECLAMO": return "Reclamo o Avería"
        case "COBERTURA_WIFI": return "Problemas de Cobertura Wi-Fi"
        case "PAUSA_VACACIONES": return "Pausar por Vacaciones"
        case "MEJORA_PLAN": return "Mejorar mi Plan"
        case "TRASLADO": return "Traslado de Domicilio"
        default: return cat ?? "General"
        }
    }
    
    private func clearFields() {
        newSubject = ""
        newDescription = ""
        selectedPriority = "medium"
        selectedCategory = "RECLAMO"
        selectedServiceId = ""
    }
}

struct ClientTicketsView_Previews: PreviewProvider {
    static var previews: some View {
        ClientTicketsView()
    }
}
