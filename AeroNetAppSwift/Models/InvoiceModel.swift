import Foundation

struct Invoice: Codable, Identifiable {
    let id: String
    let service_id: String?
    let period: String?
    let total: Double?
    let status: String?
    let due_date: String?
    let issue_date: String?
    let payment_link: String?
    let created_at: String?
    let service: InvoiceService?
    
    var displayTotal: String { (total ?? 0).currencyPEN }
    var statusLabel: String {
        switch status?.lowercased() {
        case "pending": return "Pendiente"
        case "paid": return "Pagado"
        case "overdue": return "Vencido"
        case "invoiced": return "Facturado"
        default: return status ?? "N/A"
        }
    }
    var dueDate: Date? { Date.fromISO(due_date) }
}

struct InvoiceService: Codable {
    let address_text: String?
    let plan: Plan?
    let customer: Customer?
}

struct InvoiceDebtsResponse: Codable {
    let totalPending: Double?
    let items: [Invoice]?
}

struct GenerateMonthlyResponse: Codable {
    let message: String?
    let count: Int?
}
