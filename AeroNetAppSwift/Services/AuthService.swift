import Foundation

class AuthService {
    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let parameters = ["email": email, "password": password]
        do {
            let body = try JSONSerialization.data(withJSONObject: parameters)
            
            NetworkManager.shared.request(endpoint: "/auth/login", method: "POST", body: body) { (result: Result<LoginResponse, Error>) in
                switch result {
                case .success(let response):
                    UserDefaults.standard.set(response.access_token, forKey: "access_token")
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
