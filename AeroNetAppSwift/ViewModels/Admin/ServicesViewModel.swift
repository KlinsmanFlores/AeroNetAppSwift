import Foundation
import SwiftUI

class ServicesViewModel: ObservableObject {
    @Published var services: [ServiceModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchServices() {
        self.isLoading = true
        self.errorMessage = nil
        ServiceService.shared.fetchAll { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    self.services = fetched
                case .failure(let error):
                    self.errorMessage = "Error al listar servicios: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
}
