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

// MARK: - Network Manager
class NetworkManager {
    static let shared = NetworkManager()
    
    // IMPORTANTE: Cambia esta URL según tu entorno
    let baseURL = "http://localhost:3000/api"
    
    private init() {}
    
    // MARK: - Request without Body
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        performRequest(endpoint: endpoint, method: method, bodyData: nil, completion: completion)
    }
    
    // MARK: - Request with Encodable Body
    func request<T: Decodable, E: Encodable>(
        endpoint: String,
        method: String = "POST",
        body: E,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        do {
            let bodyData = try JSONEncoder().encode(body)
            performRequest(endpoint: endpoint, method: method, bodyData: bodyData, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Internal Request Execution
    private func performRequest<T: Decodable>(
        endpoint: String,
        method: String,
        bodyData: Data?,
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
        
        if let data = bodyData {
            request.httpBody = data
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
                    let result = try JSONDecoder().decode(T.self, from: data)
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
    
    // MARK: - Request without typed response (for DELETE)
    func requestVoid(
        endpoint: String,
        method: String = "DELETE",
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
    
    // MARK: - POST with Dict Body
    func postJSON<T: Decodable>(
        endpoint: String,
        json: [String: Any],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        requestJSON(endpoint: endpoint, method: "POST", json: json, completion: completion)
    }
    
    // MARK: - JSON Request
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
