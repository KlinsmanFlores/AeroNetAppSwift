import Foundation
import SwiftUI

@MainActor
class ClientProfileViewModel: ObservableObject {
    @Published var customer: Customer? = nil
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    func fetchProfile() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        do {
            self.customer = try await CustomerService.shared.fetchMe()
        } catch {
            errorMessage = "Error al cargar perfil: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func updateProfile(fullName: String, phone: String, documentType: String, documentNumber: String) async -> Bool {
        guard let customerId = customer?.id else {
            errorMessage = "No se encontró el ID del cliente."
            return false
        }
        
        isSaving = true
        errorMessage = nil
        successMessage = nil
        
        let data: [String: Any] = [
            "full_name": fullName,
            "phone": phone,
            "document_type": documentType,
            "document_number": documentNumber
        ]
        
        do {
            let updated = try await CustomerService.shared.update(id: customerId, data: data)
            self.customer = updated
            successMessage = "Perfil actualizado con éxito."
            isSaving = false
            return true
        } catch {
            errorMessage = "Error al actualizar perfil: \(error.localizedDescription)"
            isSaving = false
            return false
        }
    }
}
