import Foundation
import SwiftUI

@MainActor
class InvoicesViewModel: ObservableObject {
    @Published var invoices: [Invoice] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    func fetchInvoices() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        do {
            self.invoices = try await InvoiceService.shared.fetchAll()
        } catch {
            errorMessage = "Error al obtener facturas: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func generateMonthlyInvoices(period: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        do {
            let response = try await InvoiceService.shared.generateMonthly(period: period)
            successMessage = "Facturas generadas: \(response.count ?? 0). \(response.message ?? "")"
            await fetchInvoices()
            isLoading = false
            return true
        } catch {
            errorMessage = "Error al generar facturas: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func forceBillingInvoices() async -> Bool {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        do {
            let response = try await InvoiceService.shared.forceBilling()
            successMessage = "Facturación forzada completada: \(response.count ?? 0). \(response.message ?? "")"
            await fetchInvoices()
            isLoading = false
            return true
        } catch {
            errorMessage = "Error al forzar facturación: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func deleteInvoice(id: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            try await InvoiceService.shared.delete(id: id)
            await fetchInvoices()
            isLoading = false
            return true
        } catch {
            errorMessage = "Error al eliminar factura: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
}
