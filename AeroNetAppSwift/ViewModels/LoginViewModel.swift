import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func login(authManager: AuthManager) {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Por favor ingrese correo y contraseña."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        AuthService.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    authManager.loginSuccess(response: response)
                case .failure(_):
                    self.errorMessage = "Credenciales incorrectas o error de conexión."
                }
                self.isLoading = false
            }
        }
    }
}
