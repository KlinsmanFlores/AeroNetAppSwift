import Foundation

struct User: Codable, Identifiable {
    let id: String?
    let email: String
    let role: String?
}

struct LoginResponse: Codable {
    let access_token: String
    let user: User
}
