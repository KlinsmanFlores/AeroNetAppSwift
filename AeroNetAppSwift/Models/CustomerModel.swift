import Foundation

struct Customer: Codable, Identifiable {
    let id: String?
    let user_id: String?
    let full_name: String?
    let email: String?
    let phone: String?
    let document_type: String?
    let document_number: String?
    let status: String?
    let avatar_url: String?
    let created_at: String?
    
    var displayName: String { full_name ?? email ?? "Sin nombre" }
    var statusLabel: String {
        switch status?.lowercased() {
        case "active": return "Activo"
        case "inactive": return "Inactivo"
        default: return status ?? "N/A"
        }
    }
}
