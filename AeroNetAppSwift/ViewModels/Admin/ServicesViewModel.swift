import Foundation
import SwiftUI

@MainActor
class ServicesViewModel: ObservableObject {
    @Published var services: [ServiceModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchServices() async {
        isLoading = true
        errorMessage = nil
        do {
            self.services = try await ServiceService.shared.fetchAll()
        } catch {
            errorMessage = "Error al listar servicios: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
