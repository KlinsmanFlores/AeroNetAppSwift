import Foundation
import SwiftUI

@MainActor
class ClientDebtsViewModel: ObservableObject {
    @Published var pendingInvoices: [Invoice] = []
    @Published var totalPendingDebt: Double = 0.0
    @Published var isLoading = false
    @Published var isPaying = false
    @Published var paymentSuccess = false
    @Published var errorMessage: String? = nil
    
    func fetchDebts() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await InvoiceService.shared.fetchMyDebts()
            self.totalPendingDebt = response.totalPending ?? 0.0
            self.pendingInvoices = response.items ?? []
        } catch {
            errorMessage = "Error al consultar tus deudas: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func payInvoice(id: String) async -> Bool {
        isPaying = true
        errorMessage = nil
        paymentSuccess = false
        do {
            _ = try await PaymentService.shared.simulate(invoiceId: id)
            paymentSuccess = true
            await fetchDebts()
            isPaying = false
            return true
        } catch {
            errorMessage = "Error al procesar el pago simulado: \(error.localizedDescription)"
            isPaying = false
            return false
        }
    }
}
