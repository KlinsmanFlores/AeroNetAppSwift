import Foundation
import SwiftUI

class CustomersViewModel: ObservableObject {
    @Published var customers: [Customer] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchCustomers() {
        self.isLoading = true
        self.errorMessage = nil
        CustomerService.shared.fetchAll { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    self.customers = fetched
                case .failure(let error):
                    self.errorMessage = "Error al listar clientes: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
    
    func updateCustomer(id: String, fullName: String, phone: String, address: String, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        self.errorMessage = nil
        let data: [String: Any] = [
            "full_name": fullName,
            "phone": phone,
            "address": address
        ]
        CustomerService.shared.update(id: id, data: data) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.fetchCustomers()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al actualizar cliente: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
}
