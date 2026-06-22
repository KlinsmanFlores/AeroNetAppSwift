import Foundation

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case badURL
    case badResponse(Int)
    case unauthorized
    case forbidden
    case notFound
    case decodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .badURL: return "URL inválida"
        case .badResponse(let code): return "Error del servidor (\(code))"
        case .unauthorized: return "Sesión expirada. Inicia sesión nuevamente."
        case .forbidden: return "No tienes permiso para esta acción"
        case .notFound: return "Recurso no encontrado"
        case .decodingError: return "Error al procesar la respuesta"
        case .unknown(let err): return err.localizedDescription
        }
    }
}

// MARK: - Network Manager (Semana 13 — async/await)
class NetworkManager {
    static let shared = NetworkManager()
    
    // IMPORTANTE: Cambia esta URL según tu entorno
    let baseURL = "http://localhost:3000/api"
    
    private init() {}
    
    // MARK: - Generic Request
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // JWT Token
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Body
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse(0)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        default:
            throw NetworkError.badResponse(httpResponse.statusCode)
        }
    }
    
    // MARK: - Request sin respuesta tipada (para DELETE, etc)
    func requestVoid(
        endpoint: String,
        method: String = "DELETE",
        body: Encodable? = nil
    ) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw NetworkError.badResponse(code)
        }
    }
    
    // MARK: - POST con body dict genérico
    func postJSON<T: Decodable>(
        endpoint: String,
        json: [String: Any]
    ) async throws -> T {
        try await requestJSON(endpoint: endpoint, method: "POST", json: json)
    }
    
    // MARK: - JSON Request with method (POST, PATCH, etc)
    func requestJSON<T: Decodable>(
        endpoint: String,
        method: String,
        json: [String: Any]
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: json)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            if code == 401 { throw NetworkError.unauthorized }
            if code == 403 { throw NetworkError.forbidden }
            throw NetworkError.badResponse(code)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
