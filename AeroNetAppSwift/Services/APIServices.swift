import Foundation

class CustomerService {
    static let shared = CustomerService()
    func fetchAll(completion: @escaping (Result<[Customer], Error>) -> Void) { NetworkManager.shared.request(endpoint: "/customers", completion: completion) }
    func fetchMe(completion: @escaping (Result<Customer, Error>) -> Void) { NetworkManager.shared.request(endpoint: "/customers/me", completion: completion) }
    func update(id: String, data: [String: Any], completion: @escaping (Result<Customer, Error>) -> Void) { NetworkManager.shared.requestJSON(endpoint: "/customers/\(id)", method: "PATCH", json: data, completion: completion) }
}

class PlanService {
    static let shared = PlanService()
    func fetchAll(completion: @escaping (Result<[Plan], Error>) -> Void) { NetworkManager.shared.request(endpoint: "/plans", completion: completion) }
    func create(_ data: [String: Any], completion: @escaping (Result<Plan, Error>) -> Void) { NetworkManager.shared.postJSON(endpoint: "/plans", json: data, completion: completion) }
    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void) { NetworkManager.shared.requestVoid(endpoint: "/plans/\(id)", completion: completion) }
}

class ServiceService {
    static let shared = ServiceService()
    func fetchAll(completion: @escaping (Result<[ServiceModel], Error>) -> Void) { NetworkManager.shared.request(endpoint: "/services", completion: completion) }
    func fetchMyServices(completion: @escaping (Result<[ServiceModel], Error>) -> Void) { NetworkManager.shared.request(endpoint: "/services/my-services", completion: completion) }
    func requestWithTicket(_ body: CreateServiceWithTicketRequest, completion: @escaping (Result<[String: AnyCodable], Error>) -> Void) {
        NetworkManager.shared.request(endpoint: "/services/with-ticket", method: "POST", body: body, completion: completion)
    }
}

class InvoiceService {
    static let shared = InvoiceService()
    func fetchAll(completion: @escaping (Result<[Invoice], Error>) -> Void) { NetworkManager.shared.request(endpoint: "/invoices", completion: completion) }
    func fetchMyDebts(completion: @escaping (Result<InvoiceDebtsResponse, Error>) -> Void) { NetworkManager.shared.request(endpoint: "/invoices/my-debts", completion: completion) }
    func generateMonthly(period: String, completion: @escaping (Result<GenerateMonthlyResponse, Error>) -> Void) {
        NetworkManager.shared.request(endpoint: "/invoices/generate-monthly?period=\(period)", method: "POST", completion: completion)
    }
    func forceBilling(completion: @escaping (Result<GenerateMonthlyResponse, Error>) -> Void) {
        NetworkManager.shared.request(endpoint: "/invoices/force-billing", method: "POST", completion: completion)
    }
    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void) { NetworkManager.shared.requestVoid(endpoint: "/invoices/\(id)", completion: completion) }
}

class PaymentService {
    static let shared = PaymentService()
    func fetchAll(completion: @escaping (Result<[Payment], Error>) -> Void) { NetworkManager.shared.request(endpoint: "/payments", completion: completion) }
    func simulate(invoiceId: String, completion: @escaping (Result<Payment, Error>) -> Void) {
        NetworkManager.shared.request(endpoint: "/payments/simulate/\(invoiceId)", method: "POST", completion: completion)
    }
}

class TicketService {
    static let shared = TicketService()
    func fetchAll(completion: @escaping (Result<[Ticket], Error>) -> Void) { NetworkManager.shared.request(endpoint: "/tickets", completion: completion) }
    func fetchMyTickets(completion: @escaping (Result<[Ticket], Error>) -> Void) { NetworkManager.shared.request(endpoint: "/tickets/my-tickets", completion: completion) }
    func create(_ body: CreateTicketRequest, completion: @escaping (Result<Ticket, Error>) -> Void) {
        NetworkManager.shared.request(endpoint: "/tickets", method: "POST", body: body, completion: completion)
    }
    func update(id: String, data: [String: Any], completion: @escaping (Result<Ticket, Error>) -> Void) {
        NetworkManager.shared.requestJSON(endpoint: "/tickets/\(id)", method: "PATCH", json: data, completion: completion)
    }
}

class TechnicianService {
    static let shared = TechnicianService()
    func fetchAll(completion: @escaping (Result<[Technician], Error>) -> Void) { NetworkManager.shared.request(endpoint: "/technician", completion: completion) }
    func create(_ body: CreateTechnicianRequest, completion: @escaping (Result<Technician, Error>) -> Void) {
        NetworkManager.shared.request(endpoint: "/technician", method: "POST", body: body, completion: completion)
    }
    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void) { NetworkManager.shared.requestVoid(endpoint: "/technician/\(id)", completion: completion) }
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
