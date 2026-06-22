import Foundation
import SwiftUI

@MainActor
class ClientHomeViewModel: ObservableObject {
    @Published var customer: Customer? = nil
    @Published var myServices: [ServiceModel] = []
    @Published var totalPendingDebt: Double = 0.0
    @Published var pendingInvoices: [Invoice] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        do {
            async let fetchMe = CustomerService.shared.fetchMe()
            async let fetchServices = ServiceService.shared.fetchMyServices()
            async let fetchDebts = InvoiceService.shared.fetchMyDebts()
            
            let (me, services, debts) = try await (fetchMe, fetchServices, fetchDebts)
            self.customer = me
            self.myServices = services
            self.totalPendingDebt = debts.totalPending ?? 0.0
            self.pendingInvoices = debts.items ?? []
        } catch {
            errorMessage = "Error al cargar tu dashboard: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
