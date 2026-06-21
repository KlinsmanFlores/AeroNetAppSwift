import Foundation

class AuthService {
    func login(email: String, password: String) async throws -> LoginResponse {
        let parameters = ["email": email, "password": password]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        
        let response: LoginResponse = try await NetworkManager.shared.request(
            endpoint: "/auth/login",
            method: "POST",
            body: body
        )
        
        UserDefaults.standard.set(response.access_token, forKey: "access_token")
        
        return response
    }
}
