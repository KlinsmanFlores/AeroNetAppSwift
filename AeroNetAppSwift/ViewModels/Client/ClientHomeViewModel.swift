import Foundation
import SwiftUI

class ClientHomeViewModel: ObservableObject {
    @Published var customer: Customer? = nil
    @Published var myServices: [ServiceModel] = []
    @Published var totalPendingDebt: Double = 0.0
    @Published var pendingInvoices: [Invoice] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func loadDashboard() {
        self.isLoading = true
        self.errorMessage = nil
        
        let group = DispatchGroup()
        
        var fetchedCustomer: Customer?
        var fetchedServices: [ServiceModel] = []
        var fetchedDebts: InvoiceDebtsResponse?
        var fetchError: Error?
        
        group.enter()
        CustomerService.shared.fetchMe { result in
            switch result {
            case .success(let customer): fetchedCustomer = customer
            case .failure(let err): fetchError = err
            }
            group.leave()
        }
        
        group.enter()
        ServiceService.shared.fetchMyServices { result in
            switch result {
            case .success(let services): fetchedServices = services
            case .failure(let err): fetchError = err
            }
            group.leave()
        }
        
        group.enter()
        InvoiceService.shared.fetchMyDebts { result in
            switch result {
            case .success(let debts): fetchedDebts = debts
            case .failure(let err): fetchError = err
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            if let error = fetchError {
                self.errorMessage = "Error al cargar tu dashboard: \(error.localizedDescription)"
            } else {
                self.customer = fetchedCustomer
                self.myServices = fetchedServices
                self.totalPendingDebt = fetchedDebts?.totalPending ?? 0.0
                self.pendingInvoices = fetchedDebts?.items ?? []
            }
        }
    }
}
