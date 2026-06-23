import Foundation
import SwiftUI

class PaymentsViewModel: ObservableObject {
    @Published var payments: [Payment] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchPayments() {
        self.isLoading = true
        self.errorMessage = nil
        PaymentService.shared.fetchAll { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    self.payments = fetched
                case .failure(let error):
                    self.errorMessage = "Error al listar pagos: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
}
