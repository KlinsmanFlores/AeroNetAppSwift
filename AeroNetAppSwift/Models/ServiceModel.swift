import Foundation

struct ServiceModel: Codable, Identifiable {
    let id: String
    let customer_id: String?
    let plan_id: String?
    let address_text: String?
    let latitude: Double?
    let longitude: Double?
    let status: String?
    let billing_day: Int?
    let monthly_amount: Double?
    let created_at: String?
    let plan: Plan?
    let customer: Customer?
    
    var statusLabel: String {
        switch status?.lowercased() {
        case "active": return "Activo"
        case "pending": return "Pendiente"
        case "suspended": return "Suspendido"
        default: return status ?? "N/A"
        }
    }
}

struct CreateServiceWithTicketRequest: Codable {
    let plan_id: String
    let address_text: String
    let full_name: String
    let document_type: String
    let document_number: String
    let phone: String
    let latitude: Double?
    let longitude: Double?
    let ticket_subject: String?
    let ticket_description: String?
}
