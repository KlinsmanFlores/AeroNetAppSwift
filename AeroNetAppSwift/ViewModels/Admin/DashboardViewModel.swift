import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var totalCustomers: Int = 0
    @Published var totalActiveServices: Int = 0
    @Published var totalPendingTickets: Int = 0
    @Published var totalOutstandingAmount: Double = 0.0
    @Published var recentPayments: [Payment] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func loadDashboardData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let customers = CustomerService.shared.fetchAll()
            async let services = ServiceService.shared.fetchAll()
            async let tickets = TicketService.shared.fetchAll()
            async let invoices = InvoiceService.shared.fetchAll()
            async let payments = PaymentService.shared.fetchAll()
            
            let (fetchedCustomers, fetchedServices, fetchedTickets, fetchedInvoices, fetchedPayments) = try await (customers, services, tickets, invoices, payments)
            
            self.totalCustomers = fetchedCustomers.count
            self.totalActiveServices = fetchedServices.filter { $0.status?.lowercased() == "active" }.count
            self.totalPendingTickets = fetchedTickets.filter { $0.status?.lowercased() == "open" || $0.status?.lowercased() == "in_progress" }.count
            self.totalOutstandingAmount = fetchedInvoices.filter { $0.status?.lowercased() == "pending" }.reduce(0.0) { $0 + ($1.total ?? 0.0) }
            
            // Sort payments by created_at desc and take top 5
            self.recentPayments = Array(fetchedPayments.sorted(by: { ($0.created_at ?? "") > ($1.created_at ?? "") }).prefix(5))
            
        } catch {
            errorMessage = "Error al cargar datos del panel: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
