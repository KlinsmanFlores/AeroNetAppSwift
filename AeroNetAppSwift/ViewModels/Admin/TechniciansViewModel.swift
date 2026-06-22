import Foundation
import SwiftUI

@MainActor
class TechniciansViewModel: ObservableObject {
    @Published var technicians: [Technician] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchTechnicians() async {
        isLoading = true
        errorMessage = nil
        do {
            self.technicians = try await TechnicianService.shared.fetchAll()
        } catch {
            errorMessage = "Error al listar técnicos: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func createTechnician(email: String, password: String, fullName: String, phone: String?, docNumber: String?, specialty: String?) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let body = CreateTechnicianRequest(
            email: email,
            password: password,
            full_name: fullName,
            phone: phone,
            document_number: docNumber,
            specialization: specialty
        )
        
        do {
            _ = try await TechnicianService.shared.create(body)
            await fetchTechnicians()
            isLoading = false
            return true
        } catch {
            errorMessage = "Error al registrar técnico: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func deleteTechnician(id: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            try await TechnicianService.shared.delete(id: id)
            await fetchTechnicians()
            isLoading = false
            return true
        } catch {
            errorMessage = "Error al eliminar técnico: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
}
