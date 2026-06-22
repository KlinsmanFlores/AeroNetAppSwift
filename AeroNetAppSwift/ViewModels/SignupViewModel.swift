import Foundation
import SwiftUI

@MainActor
class SignupViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSuccess = false
    
    func signup(authManager: AuthManager) async {
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
        
        do {
            let response = try await AuthService.shared.signup(email: email, password: password, fullName: fullName)
            isSuccess = true
            // Si el backend devuelve un token directamente, hacemos login
            if let token = response.access_token, let user = response.user {
                authManager.loginSuccess(response: LoginResponse(access_token: token, user: user))
            } else {
                errorMessage = "Registro exitoso. Por favor inicie sesión."
            }
        } catch {
            errorMessage = "Error al registrarse. El correo podría estar en uso."
        }
        isLoading = false
    }
}
