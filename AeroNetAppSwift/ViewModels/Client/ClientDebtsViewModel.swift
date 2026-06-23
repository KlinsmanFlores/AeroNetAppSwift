import Foundation
import SwiftUI

class ClientDebtsViewModel: ObservableObject {
    @Published var pendingInvoices: [Invoice] = []
    @Published var totalPendingDebt: Double = 0.0
    @Published var isLoading = false
    @Published var isPaying = false
    @Published var paymentSuccess = false
    @Published var errorMessage: String? = nil
    
    func fetchDebts() {
        self.isLoading = true
        self.errorMessage = nil
        
        InvoiceService.shared.fetchMyDebts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.totalPendingDebt = response.totalPending ?? 0.0
                    self.pendingInvoices = response.items ?? []
                case .failure(let error):
                    self.errorMessage = "Error al consultar tus deudas: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
    
    func payInvoice(id: String, completion: @escaping (Bool) -> Void) {
        self.isPaying = true
        self.errorMessage = nil
        self.paymentSuccess = false
        
        PaymentService.shared.simulate(invoiceId: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.paymentSuccess = true
                    self.fetchDebts()
                    self.isPaying = false
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al procesar el pago simulado: \(error.localizedDescription)"
                    self.isPaying = false
                    completion(false)
                }
            }
        }
    }
}
