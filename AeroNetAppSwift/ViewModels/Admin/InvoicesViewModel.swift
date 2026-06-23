import Foundation
import SwiftUI

class InvoicesViewModel: ObservableObject {
    @Published var invoices: [Invoice] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    func fetchInvoices() {
        self.isLoading = true
        self.errorMessage = nil
        self.successMessage = nil
        InvoiceService.shared.fetchAll { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    self.invoices = fetched
                case .failure(let error):
                    self.errorMessage = "Error al obtener facturas: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
    
    func generateMonthlyInvoices(period: String, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        self.errorMessage = nil
        self.successMessage = nil
        InvoiceService.shared.generateMonthly(period: period) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.successMessage = "Facturas generadas: \(response.count ?? 0). \(response.message ?? "")"
                    self.fetchInvoices()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al generar facturas: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
    
    func forceBillingInvoices(completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        self.errorMessage = nil
        self.successMessage = nil
        InvoiceService.shared.forceBilling { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.successMessage = "Facturación forzada completada: \(response.count ?? 0). \(response.message ?? "")"
                    self.fetchInvoices()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al forzar facturación: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
    
    func deleteInvoice(id: String, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        self.errorMessage = nil
        InvoiceService.shared.delete(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.fetchInvoices()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al eliminar factura: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
}
