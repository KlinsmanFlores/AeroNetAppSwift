import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var totalCustomers: Int = 0
    @Published var totalActiveServices: Int = 0
    @Published var totalPendingTickets: Int = 0
    @Published var totalOutstandingAmount: Double = 0.0
    @Published var recentPayments: [Payment] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func loadDashboardData() {
        self.isLoading = true
        self.errorMessage = nil
        
        let group = DispatchGroup()
        
        var fetchedCustomers: [Customer] = []
        var fetchedServices: [ServiceModel] = []
        var fetchedTickets: [Ticket] = []
        var fetchedInvoices: [Invoice] = []
        var fetchedPayments: [Payment] = []
        var fetchError: Error?
        
        group.enter()
        CustomerService.shared.fetchAll { result in
            switch result {
            case .success(let data): fetchedCustomers = data
            case .failure(let err): fetchError = err
            }
            group.leave()
        }
        
        group.enter()
        ServiceService.shared.fetchAll { result in
            switch result {
            case .success(let data): fetchedServices = data
            case .failure(let err): fetchError = err
            }
            group.leave()
        }
        
        group.enter()
        TicketService.shared.fetchAll { result in
            switch result {
            case .success(let data): fetchedTickets = data
            case .failure(let err): fetchError = err
            }
            group.leave()
        }
        
        group.enter()
        InvoiceService.shared.fetchAll { result in
            switch result {
            case .success(let data): fetchedInvoices = data
            case .failure(let err): fetchError = err
            }
            group.leave()
        }
        
        group.enter()
        PaymentService.shared.fetchAll { result in
            switch result {
            case .success(let data): fetchedPayments = data
            case .failure(let err): fetchError = err
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            if let error = fetchError {
                self.errorMessage = "Error al cargar datos del panel: \(error.localizedDescription)"
            } else {
                self.totalCustomers = fetchedCustomers.count
                self.totalActiveServices = fetchedServices.filter { $0.status?.lowercased() == "active" }.count
                self.totalPendingTickets = fetchedTickets.filter { $0.status?.lowercased() == "open" || $0.status?.lowercased() == "in_progress" }.count
                self.totalOutstandingAmount = fetchedInvoices.filter { $0.status?.lowercased() == "pending" }.reduce(0.0) { $0 + ($1.total ?? 0.0) }
                
                self.recentPayments = Array(fetchedPayments.sorted(by: { ($0.created_at ?? "") > ($1.created_at ?? "") }).prefix(5))
            }
        }
    }
}
