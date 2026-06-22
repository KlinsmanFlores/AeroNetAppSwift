import Foundation

class CustomerService {
    static let shared = CustomerService()
    func fetchAll() async throws -> [Customer] { try await NetworkManager.shared.request(endpoint: "/customers") }
    func fetchMe() async throws -> Customer { try await NetworkManager.shared.request(endpoint: "/customers/me") }
    func update(id: String, data: [String: Any]) async throws -> Customer { try await NetworkManager.shared.requestJSON(endpoint: "/customers/\(id)", method: "PATCH", json: data) }
}

class PlanService {
    static let shared = PlanService()
    func fetchAll() async throws -> [Plan] { try await NetworkManager.shared.request(endpoint: "/plans") }
    func create(_ data: [String: Any]) async throws -> Plan { try await NetworkManager.shared.postJSON(endpoint: "/plans", json: data) }
    func delete(id: String) async throws { try await NetworkManager.shared.requestVoid(endpoint: "/plans/\(id)") }
}

class ServiceService {
    static let shared = ServiceService()
    func fetchAll() async throws -> [ServiceModel] { try await NetworkManager.shared.request(endpoint: "/services") }
    func fetchMyServices() async throws -> [ServiceModel] { try await NetworkManager.shared.request(endpoint: "/services/my-services") }
    func requestWithTicket(_ body: CreateServiceWithTicketRequest) async throws -> [String: AnyCodable] {
        try await NetworkManager.shared.request(endpoint: "/services/with-ticket", method: "POST", body: body)
    }
}

class InvoiceService {
    static let shared = InvoiceService()
    func fetchAll() async throws -> [Invoice] { try await NetworkManager.shared.request(endpoint: "/invoices") }
    func fetchMyDebts() async throws -> InvoiceDebtsResponse { try await NetworkManager.shared.request(endpoint: "/invoices/my-debts") }
    func generateMonthly(period: String) async throws -> GenerateMonthlyResponse {
        try await NetworkManager.shared.request(endpoint: "/invoices/generate-monthly?period=\(period)", method: "POST")
    }
    func forceBilling() async throws -> GenerateMonthlyResponse {
        try await NetworkManager.shared.request(endpoint: "/invoices/force-billing", method: "POST")
    }
    func delete(id: String) async throws { try await NetworkManager.shared.requestVoid(endpoint: "/invoices/\(id)") }
}

class PaymentService {
    static let shared = PaymentService()
    func fetchAll() async throws -> [Payment] { try await NetworkManager.shared.request(endpoint: "/payments") }
    func simulate(invoiceId: String) async throws -> Payment {
        try await NetworkManager.shared.request(endpoint: "/payments/simulate/\(invoiceId)", method: "POST")
    }
}

class TicketService {
    static let shared = TicketService()
    func fetchAll() async throws -> [Ticket] { try await NetworkManager.shared.request(endpoint: "/tickets") }
    func fetchMyTickets() async throws -> [Ticket] { try await NetworkManager.shared.request(endpoint: "/tickets/my-tickets") }
    func create(_ body: CreateTicketRequest) async throws -> Ticket {
        try await NetworkManager.shared.request(endpoint: "/tickets", method: "POST", body: body)
    }
    func update(id: String, data: [String: Any]) async throws -> Ticket {
        try await NetworkManager.shared.requestJSON(endpoint: "/tickets/\(id)", method: "PATCH", json: data)
    }
}

class TechnicianService {
    static let shared = TechnicianService()
    func fetchAll() async throws -> [Technician] { try await NetworkManager.shared.request(endpoint: "/technician") }
    func create(_ body: CreateTechnicianRequest) async throws -> Technician {
        try await NetworkManager.shared.request(endpoint: "/technician", method: "POST", body: body)
    }
    func delete(id: String) async throws { try await NetworkManager.shared.requestVoid(endpoint: "/technician/\(id)") }
}

// Helper para respuestas JSON genéricas
struct AnyCodable: Codable {
    let value: String?
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try? container.decode(String.self)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
