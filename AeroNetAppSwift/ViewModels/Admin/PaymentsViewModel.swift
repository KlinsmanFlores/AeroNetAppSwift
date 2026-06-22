import Foundation
import SwiftUI

@MainActor
class PaymentsViewModel: ObservableObject {
    @Published var payments: [Payment] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchPayments() async {
        isLoading = true
        errorMessage = nil
        do {
            self.payments = try await PaymentService.shared.fetchAll()
        } catch {
            errorMessage = "Error al listar pagos: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
