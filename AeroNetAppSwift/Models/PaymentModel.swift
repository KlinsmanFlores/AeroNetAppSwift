import Foundation

struct Payment: Codable, Identifiable {
    let id: String
    let customer_id: String?
    let service_id: String?
    let amount_received: Double?
    let payment_method: String?
    let transaction_reference: String?
    let provider: String?
    let payment_mode: String?
    let payment_date: String?
    let created_at: String?
    let customer: Customer?
    
    var displayAmount: String { (amount_received ?? 0).currencyPEN }
    var displayMethod: String {
        switch payment_method?.uppercased() {
        case "CASH": return "Efectivo"
        case "TRANSFER": return "Transferencia"
        case "CARD": return "Tarjeta"
        case "YAPE": return "Yape"
        default: return payment_method ?? "N/A"
        }
    }
}
