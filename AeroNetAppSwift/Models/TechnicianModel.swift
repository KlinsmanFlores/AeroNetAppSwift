import Foundation

struct Technician: Codable, Identifiable {
    let id: String
    let user_id: String?
    let full_name: String?
    let email: String?
    let phone: String?
    let specialty: String?
    let status: String?
    let created_at: String?
    
    var displayName: String { full_name ?? email ?? "Sin nombre" }
}

struct CreateTechnicianRequest: Codable {
    let email: String
    let password: String
    let full_name: String
    let phone: String?
    let document_number: String?
    let specialization: String?
}
