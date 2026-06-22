import Foundation
import SwiftUI

@MainActor
class ClientInvoicesViewModel: ObservableObject {
    @Published var invoices: [Invoice] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchInvoices() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await InvoiceService.shared.fetchMyDebts()
            // Filtramos las facturas correspondientes
            self.invoices = response.items ?? []
        } catch {
            errorMessage = "Error al obtener tus comprobantes: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
