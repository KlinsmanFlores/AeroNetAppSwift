import Foundation
import SwiftUI

@MainActor
class ClientTicketsViewModel: ObservableObject {
    @Published var tickets: [Ticket] = []
    @Published var isLoading = false
    @Published var isCreating = false
    @Published var errorMessage: String? = nil
    
    func fetchTickets() async {
        isLoading = true
        errorMessage = nil
        do {
            self.tickets = try await TicketService.shared.fetchMyTickets()
        } catch {
            errorMessage = "Error al obtener tus tickets: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func createTicket(serviceId: String?, type: String, subject: String, description: String, priority: String, category: String?) async -> Bool {
        isCreating = true
        errorMessage = nil
        
        let body = CreateTicketRequest(
            service_id: serviceId,
            type: type,
            subject: subject,
            description: description,
            priority: priority,
            category: category
        )
        
        do {
            _ = try await TicketService.shared.create(body)
            await fetchTickets()
            isCreating = false
            return true
        } catch {
            errorMessage = "Error al crear ticket: \(error.localizedDescription)"
            isCreating = false
            return false
        }
    }
}
