import Foundation
import SwiftUI

class TechniciansViewModel: ObservableObject {
    @Published var technicians: [Technician] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchTechnicians() {
        self.isLoading = true
        self.errorMessage = nil
        TechnicianService.shared.fetchAll { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    self.technicians = fetched
                case .failure(let error):
                    self.errorMessage = "Error al listar técnicos: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
    
    func createTechnician(email: String, password: String, fullName: String, phone: String?, docNumber: String?, specialty: String?, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        self.errorMessage = nil
        
        let body = CreateTechnicianRequest(
            email: email,
            password: password,
            full_name: fullName,
            phone: phone,
            document_number: docNumber,
            specialization: specialty
        )
        
        TechnicianService.shared.create(body) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.fetchTechnicians()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al registrar técnico: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
    
    func deleteTechnician(id: String, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        self.errorMessage = nil
        TechnicianService.shared.delete(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.fetchTechnicians()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al eliminar técnico: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
}
