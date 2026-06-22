import Foundation

struct Ticket: Codable, Identifiable {
    let id: String
    let customer_id: String?
    let service_id: String?
    let type: String?
    let subject: String?
    let description: String?
    let status: String?
    let priority: String?
    let category: String?
    let technician_id: String?
    let created_at: String?
    let customer: Customer?
    let service: ServiceModel?
    
    var statusLabel: String {
        switch status?.lowercased() {
        case "open": return "Abierto"
        case "in_progress": return "En Progreso"
        case "resolved": return "Resuelto"
        case "closed": return "Cerrado"
        default: return status ?? "N/A"
        }
    }
    var priorityLabel: String {
        switch priority?.lowercased() {
        case "low": return "Baja"
        case "medium": return "Media"
        case "high": return "Alta"
        case "urgent": return "Urgente"
        default: return priority ?? "N/A"
        }
    }
}

struct CreateTicketRequest: Codable {
    let service_id: String?
    let type: String
    let subject: String
    let description: String
    let priority: String
    let category: String?
}
