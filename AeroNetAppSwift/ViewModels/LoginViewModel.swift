import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService()
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await authService.login(email: email, password: password)
                print("Login successful for user: \(response.user.email)")
                isLoading = false
            } catch {
                errorMessage = "Login failed. Please check your credentials."
                isLoading = false
            }
        }
    }
}
