import Foundation
import SwiftUI
// MARK: - Auth Manager (Estado global de autenticación)
@MainActor
class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var userRole: String = ""
    @Published var isLoading = true
    
    var token: String? { UserDefaults.standard.string(forKey: "access_token") }
    
    init() {
        checkExistingSession()
    }
    
    func checkExistingSession() {
        if let token = UserDefaults.standard.string(forKey: "access_token"),
           let role = UserDefaults.standard.string(forKey: "user_role"),
           let email = UserDefaults.standard.string(forKey: "user_email"),
           let userId = UserDefaults.standard.string(forKey: "user_id"),
           !token.isEmpty {
            self.currentUser = User(id: userId, email: email, role: role)
            self.userRole = role
            self.isLoggedIn = true
        }
        self.isLoading = false
    }
    
    func loginSuccess(response: LoginResponse) {
        UserDefaults.standard.set(response.access_token, forKey: "access_token")
        UserDefaults.standard.set(response.user.role ?? "", forKey: "user_role")
        UserDefaults.standard.set(response.user.email, forKey: "user_email")
        UserDefaults.standard.set(response.user.id ?? "", forKey: "user_id")
        
        self.currentUser = response.user
        self.userRole = response.user.role ?? ""
        withAnimation(.easeInOut(duration: 0.5)) {
            self.isLoggedIn = true
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "user_role")
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "user_id")
        
        AuthService.shared.logout()
        self.currentUser = nil
        self.userRole = ""
        withAnimation(.easeInOut(duration: 0.5)) {
            self.isLoggedIn = false
        }
    }
    
    var isAdmin: Bool { userRole == "admin" }
    var isCustomer: Bool { userRole == "customer" }
    var isProspect: Bool { userRole == "prospect" || userRole.isEmpty }
    var isTechnician: Bool { userRole == "technician" }
}
