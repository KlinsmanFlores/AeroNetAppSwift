import Foundation
import SwiftData

// MARK: - SwiftData: Cachear planes para acceso offline (Semana 11)
@Model
class CachedPlan {
    @Attribute(.unique) var planId: String
    var name: String
    var price: Double
    var speedMbps: Double
    var planDescription: String
    var cachedDate: Date
    
    init(from plan: Plan) {
        self.planId = plan.id
        self.name = plan.name ?? ""
        self.price = plan.price ?? 0
        self.speedMbps = plan.speed_mbps ?? 0
        self.planDescription = plan.description ?? ""
        self.cachedDate = Date()
    }
    
    func toPlan() -> Plan {
        return Plan(
            id: planId,
            name: name,
            price: price,
            speed_mbps: speedMbps,
            description: planDescription,
            status: "active",
            created_at: nil
        )
    }
}
