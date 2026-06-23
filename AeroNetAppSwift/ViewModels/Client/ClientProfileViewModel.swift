import Foundation
import SwiftUI

class ClientProfileViewModel: ObservableObject {
    @Published var customer: Customer? = nil
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    func fetchProfile() {
        self.isLoading = true
        self.errorMessage = nil
        self.successMessage = nil
        
        CustomerService.shared.fetchMe { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let me):
                    self.customer = me
                case .failure(let error):
                    self.errorMessage = "Error al cargar perfil: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
    
    func updateProfile(fullName: String, phone: String, documentType: String, documentNumber: String, completion: @escaping (Bool) -> Void) {
        guard let customerId = customer?.id else {
            self.errorMessage = "No se encontró el ID del cliente."
            completion(false)
            return
        }
        
        self.isSaving = true
        self.errorMessage = nil
        self.successMessage = nil
        
        let data: [String: Any] = [
            "full_name": fullName,
            "phone": phone,
            "document_type": documentType,
            "document_number": documentNumber
        ]
        
        CustomerService.shared.update(id: customerId, data: data) { result in
            DispatchQueue.main.async {
                self.isSaving = false
                switch result {
                case .success(let updated):
                    self.customer = updated
                    self.successMessage = "Perfil actualizado con éxito."
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al actualizar perfil: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
}
