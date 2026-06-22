import Foundation
import SwiftUI

@MainActor
class TicketsViewModel: ObservableObject {
    @Published var tickets: [Ticket] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchTickets() async {
        isLoading = true
        errorMessage = nil
        do {
            self.tickets = try await TicketService.shared.fetchAll()
        } catch {
            errorMessage = "Error al obtener tickets: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func updateTicket(id: String, status: String, technicianId: String?, priority: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        var data: [String: Any] = [
            "status": status,
            "priority": priority
        ]
        
        if let techId = technicianId, !techId.isEmpty {
            data["technician_id"] = techId
        } else {
            data["technician_id"] = NSNull() // Para desasignar
        }
        
        do {
            _ = try await TicketService.shared.update(id: id, data: data)
            await fetchTickets()
            isLoading = false
            return true
        } catch {
            errorMessage = "Error al actualizar ticket: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
}
