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
        body: Encodable? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.unknown(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.badResponse(0)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.badResponse(httpResponse.statusCode)))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case 401:
                completion(.failure(NetworkError.unauthorized))
            case 403:
                completion(.failure(NetworkError.forbidden))
            case 404:
                completion(.failure(NetworkError.notFound))
            default:
                completion(.failure(NetworkError.badResponse(httpResponse.statusCode)))
            }
        }.resume()
    }
    
    // MARK: - Request sin respuesta tipada (para DELETE, etc)
    func requestVoid(
        endpoint: String,
        method: String = "DELETE",
        body: Encodable? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(NetworkError.unknown(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.failure(NetworkError.badResponse(code)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    // MARK: - POST con body dict genérico
    func postJSON<T: Decodable>(
        endpoint: String,
        json: [String: Any],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        requestJSON(endpoint: endpoint, method: "POST", json: json, completion: completion)
    }
    
    // MARK: - JSON Request with method (POST, PATCH, etc)
    func requestJSON<T: Decodable>(
        endpoint: String,
        method: String,
        json: [String: Any],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.unknown(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.badResponse(0)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.badResponse(httpResponse.statusCode)))
                return
            }
            
            let code = httpResponse.statusCode
            if !(200...299).contains(code) {
                if code == 401 { completion(.failure(NetworkError.unauthorized)); return }
                if code == 403 { completion(.failure(NetworkError.forbidden)); return }
                completion(.failure(NetworkError.badResponse(code)))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(NetworkError.decodingError(error)))
            }
        }.resume()
    }
}
