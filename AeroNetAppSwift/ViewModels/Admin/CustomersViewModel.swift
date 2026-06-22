import Foundation
import SwiftUI

@MainActor
class CustomersViewModel: ObservableObject {
    @Published var customers: [Customer] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchCustomers() async {
        isLoading = true
        errorMessage = nil
        do {
            self.customers = try await CustomerService.shared.fetchAll()
        } catch {
            errorMessage = "Error al listar clientes: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func updateCustomer(id: String, fullName: String, phone: String, address: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        let data: [String: Any] = [
            "full_name": fullName,
            "phone": phone,
            "address": address
        ]
        do {
            _ = try await CustomerService.shared.update(id: id, data: data)
            await fetchCustomers()
            isLoading = false
            return true
        } catch {
            errorMessage = "Error al actualizar cliente: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
}
