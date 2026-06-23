import Foundation
import SwiftUI

class ClientTicketsViewModel: ObservableObject {
    @Published var tickets: [Ticket] = []
    @Published var isLoading = false
    @Published var isCreating = false
    @Published var errorMessage: String? = nil
    
    func fetchTickets() {
        self.isLoading = true
        self.errorMessage = nil
        
        TicketService.shared.fetchMyTickets { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    self.tickets = fetched
                case .failure(let error):
                    self.errorMessage = "Error al obtener tus tickets: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
    
    func createTicket(serviceId: String?, type: String, subject: String, description: String, priority: String, category: String?, completion: @escaping (Bool) -> Void) {
        self.isCreating = true
        self.errorMessage = nil
        
        let body = CreateTicketRequest(
            service_id: serviceId,
            type: type,
            subject: subject,
            description: description,
            priority: priority,
            category: category
        )
        
        TicketService.shared.create(body) { result in
            DispatchQueue.main.async {
                self.isCreating = false
                switch result {
                case .success(_):
                    self.fetchTickets()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al crear ticket: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
}
