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
            Color.theme.background
                .ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading && viewModel.tickets.isEmpty {
                    ProgressView("Cargando tickets...")
                        .foregroundColor(.white)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(iconName: "exclamationmark.triangle", title: "Error", message: error)
                } else if viewModel.tickets.isEmpty {
                    EmptyStateView(iconName: "lifepreserver", title: "Sin Tickets", message: "No hay tickets de soporte ni solicitudes registradas.")
                } else {
                    List {
                        ForEach(viewModel.tickets) { ticket in
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
                                    Label("Prioridad: \(ticket.priorityLabel)", systemName: "flag.fill")
                                        .font(.caption)
                                        .foregroundColor(priorityColor(ticket.priority))
                                    
                                    Spacer()
                                    
                                    Text("Cliente: \(ticket.customer?.full_name ?? "N/A")")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 6)
                            .listRowBackground(Color.theme.cardBackground.opacity(0.6))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTicket = ticket
                                editStatus = ticket.status ?? "open"
                                editPriority = ticket.priority ?? "medium"
                                selectedTechId = ticket.technician_id ?? ""
                                
                                Task {
                                    // Cargar técnicos para asignación
                                    if let techs = try? await TechnicianService.shared.fetchAll() {
                                        techniciansList = techs
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
        }
        .navigationTitle("Tickets & Soporte")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        await viewModel.fetchTickets()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color.theme.accent)
                }
            }
        }
        .task {
            await viewModel.fetchTickets()
        }
        .sheet(item: $selectedTicket) { ticket in
            NavigationStack {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    
                    Form {
                        Section(header: Text("Gestión del Ticket").foregroundColor(.gray)) {
                            Picker("Estado", selection: $editStatus) {
                                Text("Abierto").tag("open")
                                Text("En Progreso").tag("in_progress")
                                Text("Resuelto").tag("resolved")
                                Text("Cerrado").tag("closed")
                            }
                            .foregroundColor(.white)
                            
                            Picker("Prioridad", selection: $editPriority) {
                                Text("Baja").tag("low")
                                Text("Media").tag("medium")
                                Text("Alta").tag("high")
                                Text("Urgente").tag("urgent")
                            }
                            .foregroundColor(.white)
                        }
                        .listRowBackground(Color.theme.surface)
                        
                        Section(header: Text("Asignar Técnico").foregroundColor(.gray)) {
                            Picker("Técnico", selection: $selectedTechId) {
                                Text("Sin Asignar").tag("")
                                ForEach(techniciansList) { tech in
                                    Text(tech.displayName).tag(tech.id)
                                }
                            }
                            .foregroundColor(.white)
                        }
                        .listRowBackground(Color.theme.surface)
                    }
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
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
                            Task {
                                let success = await viewModel.updateTicket(
                                    id: ticket.id,
                                    status: editStatus,
                                    technicianId: selectedTechId,
                                    priority: editPriority
                                )
                                if success {
                                    selectedTicket = nil
                                    await viewModel.fetchTickets()
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
}

struct TicketsListView_Previews: PreviewProvider {
    static var previews: some View {
        TicketsListView()
    }
}
