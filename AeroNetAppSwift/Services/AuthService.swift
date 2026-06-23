import Foundation

class AuthService {
    static let shared = AuthService()
    
    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let body = LoginRequest(email: email, password: password)
        NetworkManager.shared.request(
            endpoint: "/auth/login",
            method: "POST",
            body: body
        ) { (result: Result<LoginResponse, Error>) in
            switch result {
            case .success(let response):
                UserDefaults.standard.set(response.access_token, forKey: "access_token")
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func signup(email: String, password: String, fullName: String, completion: @escaping (Result<SignupResponse, Error>) -> Void) {
        let body = SignupRequest(email: email, password: password, full_name: fullName)
        NetworkManager.shared.request(
            endpoint: "/auth/signup-client",
            method: "POST",
            body: body
        ) { (result: Result<SignupResponse, Error>) in
            switch result {
            case .success(let response):
                if let token = response.access_token {
                    UserDefaults.standard.set(token, forKey: "access_token")
                }
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "access_token")
    }
}
