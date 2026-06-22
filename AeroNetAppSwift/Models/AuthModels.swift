import Foundation

// MARK: - Auth Models
struct User: Codable, Identifiable {
    let id: String?
    let email: String
    let role: String?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let access_token: String
    let user: User
}

struct SignupRequest: Codable {
    let email: String
    let password: String
    let full_name: String
}

struct SignupResponse: Codable {
    let message: String?
    let user: User?
    let access_token: String?
}
