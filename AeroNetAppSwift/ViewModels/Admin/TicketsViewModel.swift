import Foundation
import SwiftUI

class TicketsViewModel: ObservableObject {
    @Published var tickets: [Ticket] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchTickets() {
        self.isLoading = true
        self.errorMessage = nil
        TicketService.shared.fetchAll { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    self.tickets = fetched
                case .failure(let error):
                    self.errorMessage = "Error al obtener tickets: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
    
    func updateTicket(id: String, status: String, technicianId: String?, priority: String, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        self.errorMessage = nil
        
        var data: [String: Any] = [
            "status": status,
            "priority": priority
        ]
        
        if let techId = technicianId, !techId.isEmpty {
            data["technician_id"] = techId
        } else {
            data["technician_id"] = NSNull() // Para desasignar
        }
        
        TicketService.shared.update(id: id, data: data) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.fetchTickets()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al actualizar ticket: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
}
