import SwiftUI

struct TicketsListView: View {
    @StateObject private var viewModel = TicketsViewModel()
    @State private var selectedTicket: Ticket? = nil
    @State private var editStatus = ""
    @State private var editPriority = ""
    @State private var selectedTechId = ""
    @State private var techniciansList: [Technician] = []
    
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
                    EmptyStateView(iconName: "lifepreserver", title: "Sin Tickets", message: "No hay tickets de soporte ni solicitudes registradas.")
                } else {
                    ticketsList
                }
            }
        }
        .navigationTitle("Tickets & Soporte")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.fetchTickets()
                    
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color.theme.accent)
                }
            }
        }
        .onAppear {
            viewModel.fetchTickets()
        }
        .sheet(item: $selectedTicket) { ticket in
            NavigationView {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    
                    Form {
                        Section(header: Text("Gestión del Ticket").foregroundColor(Color.theme.textMuted)) {
                            Picker("Estado", selection: $editStatus) {
                                Text("Abierto").tag("open")
                                Text("En Progreso").tag("in_progress")
                                Text("Resuelto").tag("resolved")
                                Text("Cerrado").tag("closed")
                            }
                            .foregroundColor(.black)
                            
                            Picker("Prioridad", selection: $editPriority) {
                                Text("Baja").tag("low")
                                Text("Media").tag("medium")
                                Text("Alta").tag("high")
                                Text("Urgente").tag("urgent")
                            }
                            .foregroundColor(.black)
                        }
                        .listRowBackground(Color.theme.surface)
                        
                        Section(header: Text("Asignar Técnico").foregroundColor(Color.theme.textMuted)) {
                            Picker("Técnico", selection: $selectedTechId) {
                                Text("Sin Asignar").tag("")
                                ForEach(techniciansList) { tech in
                                    Text(tech.displayName).tag(tech.id)
                                }
                            }
                            .foregroundColor(.black)
                        }
                        .listRowBackground(Color.theme.surface)
                    }
                    .background(Color.clear)
                }
                .navigationTitle("Detalles del Ticket")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancelar") {
                            selectedTicket = nil
                        }
                        .foregroundColor(.red)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Actualizar") {
                                viewModel.updateTicket(
                                    id: ticket.id,
                                    status: editStatus,
                                    technicianId: selectedTechId,
                                    priority: editPriority
                                ) { success in
                                    if success {
                                        selectedTicket = nil
                                        viewModel.fetchTickets()
                                    }
                                }
                        }
                        .foregroundColor(Color.theme.accent)
                    }
                }
            }
        }
    }
    
    private func priorityColor(_ priority: String?) -> Color {
        switch priority?.lowercased() {
        case "low": return .green
        case "medium": return .yellow
        case "high": return .orange
        case "urgent": return .red
        default: return .gray
        }
    }
    
    private var ticketsList: some View {
        List {
            ForEach(viewModel.tickets) { ticket in
                ticketRow(ticket)
                    .padding(.vertical, 6)
                    .listRowBackground(Color.theme.cardBackground.opacity(0.6))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTicket = ticket
                        editStatus = ticket.status ?? "open"
                        editPriority = ticket.priority ?? "medium"
                        selectedTechId = ticket.technician_id ?? ""
                        
                        TechnicianService.shared.fetchAll { result in
                            DispatchQueue.main.async {
                                if case .success(let techs) = result {
                                    techniciansList = techs
                                }
                            }
                        }
                    }
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
            
            Text(ticket.description ?? "Sin descripción")
                .font(.system(size: 13))
                .foregroundColor(Color.theme.textMuted)
                .lineLimit(2)
            
            HStack {
                Label("Prioridad: \(ticket.priorityLabel)", systemImage: "flag.fill")
                    .font(.caption)
                    .foregroundColor(priorityColor(ticket.priority))
                
                Spacer()
                
                Text("Cliente: \(ticket.customer?.full_name ?? "N/A")")
                    .font(.caption)
                    .foregroundColor(Color.theme.textMuted)
            }
        }
    }
}

struct TicketsListView_Previews: PreviewProvider {
    static var previews: some View {
        TicketsListView()
    }
}
