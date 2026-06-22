import Foundation
import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func login(authManager: AuthManager) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor ingrese correo y contraseña."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await AuthService.shared.login(email: email, password: password)
            authManager.loginSuccess(response: response)
        } catch {
            errorMessage = "Credenciales incorrectas o error de conexión."
        }
        isLoading = false
    }
}
