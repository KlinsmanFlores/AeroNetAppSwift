import Foundation
import SwiftData

// MARK: - SwiftData: Persistir sesión del usuario (Semana 11)
@Model
class UserSession {
    var token: String
    var email: String
    var role: String
    var userId: String
    var loginDate: Date
    
    init(token: String, email: String, role: String, userId: String) {
        self.token = token
        self.email = email
        self.role = role
        self.userId = userId
        self.loginDate = Date()
    }
}
