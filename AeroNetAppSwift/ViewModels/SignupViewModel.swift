import Foundation
import SwiftUI

class SignupViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSuccess = false
    
    func signup(authManager: AuthManager) {
        guard !email.isEmpty, !password.isEmpty, !fullName.isEmpty else {
            errorMessage = "Por favor, complete todos los campos."
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        AuthService.shared.signup(email: email, password: password, fullName: fullName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.isSuccess = true
                    if let token = response.access_token, let user = response.user {
                        authManager.loginSuccess(response: LoginResponse(access_token: token, user: user))
                    } else {
                        self.errorMessage = "Registro exitoso. Por favor inicie sesión."
                    }
                case .failure(_):
                    self.errorMessage = "Error al registrarse. El correo podría estar en uso."
                }
                self.isLoading = false
            }
        }
    }
}
