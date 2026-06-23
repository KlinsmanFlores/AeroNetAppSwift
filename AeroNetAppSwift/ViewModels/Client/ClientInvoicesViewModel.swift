import Foundation
import SwiftUI

class ClientInvoicesViewModel: ObservableObject {
    @Published var invoices: [Invoice] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchInvoices() {
        self.isLoading = true
        self.errorMessage = nil
        
        InvoiceService.shared.fetchMyDebts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.invoices = response.items ?? []
                case .failure(let error):
                    self.errorMessage = "Error al obtener tus comprobantes: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
}
