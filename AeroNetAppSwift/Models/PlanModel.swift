import Foundation

struct Plan: Codable, Identifiable {
    let id: String?
    let name: String?
    let price: Double?
    let speed_mbps: Double?
    let description: String?
    let status: String?
    let created_at: String?
    
    var displayPrice: String { (price ?? 0).currencyPEN }
    var displaySpeed: String { "\(Int(speed_mbps ?? 0)) Mbps" }
}
