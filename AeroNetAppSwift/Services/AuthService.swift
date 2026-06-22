import Foundation

class AuthService {
    static let shared = AuthService()
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let body = LoginRequest(email: email, password: password)
        let response: LoginResponse = try await NetworkManager.shared.request(
            endpoint: "/auth/login",
            method: "POST",
            body: body
        )
        UserDefaults.standard.set(response.access_token, forKey: "access_token")
        return response
    }
    
    func signup(email: String, password: String, fullName: String) async throws -> SignupResponse {
        let body = SignupRequest(email: email, password: password, full_name: fullName)
        let response: SignupResponse = try await NetworkManager.shared.request(
            endpoint: "/auth/signup-client",
            method: "POST",
            body: body
        )
        if let token = response.access_token {
            UserDefaults.standard.set(token, forKey: "access_token")
        }
        return response
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "access_token")
    }
}
