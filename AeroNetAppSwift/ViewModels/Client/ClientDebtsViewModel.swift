import Foundation
import SwiftUI

class ClientDebtsViewModel: ObservableObject {
    @Published var pendingInvoices: [Invoice] = []
    @Published var totalPendingDebt: Double = 0.0
    @Published var isLoading = false
    @Published var isPaying = false
    @Published var paymentSuccess = false
    @Published var errorMessage: String? = nil
    
    func fetchDebts() {
        self.isLoading = true
        self.errorMessage = nil
        
        InvoiceService.shared.fetchMyDebts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.totalPendingDebt = response.totalPending ?? 0.0
                    
                    // 🚀 COMPORTAMIENTO PREMIUM: Filtramos para que SOLO aparezcan deudas estrictamente pendientes
                    let allItems = response.items ?? []
                    self.pendingInvoices = allItems.filter { ($0.status ?? "").lowercased() == "pending" }
                    
                case .failure(let error):
                    self.errorMessage = "Error al consultar tus deudas: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
    
    func payInvoice(id: String, completion: @escaping (Bool) -> Void) {
        self.isPaying = true
        self.errorMessage = nil
        self.paymentSuccess = false
        
        // 1️⃣ Simulamos el pago en el backend
        PaymentService.shared.simulate(invoiceId: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("✅ Simulación de pago exitosa. Generando documento...")
                    self.forzarGeneracionNubefact(invoiceId: id, completion: completion)
                    
                case .failure(let error):
                    let errorDesc = error.localizedDescription.lowercased()
                    
                    // Manejo del candado 400 o fallos de decoding
                    if errorDesc.contains("400") || errorDesc.contains("decoding") || errorDesc.contains("respuesta") {
                        print("⚠️ Pago previo registrado. Sincronizando Nubefact por seguridad...")
                        self.forzarGeneracionNubefact(invoiceId: id, completion: completion)
                    } else {
                        self.errorMessage = "Error al procesar el pago simulado: \(error.localizedDescription)"
                        self.isPaying = false
                        completion(false)
                    }
                }
            }
        }
    }
    
    // 2️⃣ Generación forzada manual vía endpoint de pruebas manuales de tu Swagger
    private func forzarGeneracionNubefact(invoiceId: String, completion: @escaping (Bool) -> Void) {
        let endpoint = "/test-tasks/generate-nubefact/\(invoiceId)"
        guard let url = URL(string: NetworkManager.shared.baseURL + endpoint) else {
            self.finalizarFlujoPago(completion: completion)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            print("⚡ Proceso Nubefact gatillado para la factura: \(invoiceId)")
            self.forzarSincronizacionComprobante(invoiceId: invoiceId)
            
            DispatchQueue.main.async {
                self.finalizarFlujoPago(completion: completion)
            }
        }.resume()
    }
    
    // 🔄 3️⃣ Forzar sincronización intermedia
    private func forzarSincronizacionComprobante(invoiceId: String) {
        let endpoint = "/electronic-documents/invoice/\(invoiceId)/refresh"
        guard let url = URL(string: NetworkManager.shared.baseURL + endpoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // 🏁 4️⃣ Cierre limpio con filtro preventivo local inmediato
    private func finalizarFlujoPago(completion: @escaping (Bool) -> Void) {
        self.isPaying = false
        self.paymentSuccess = true
        
        InvoiceService.shared.fetchMyDebts { refreshResult in
            DispatchQueue.main.async {
                if case .success(let response) = refreshResult {
                    self.totalPendingDebt = response.totalPending ?? 0.0
                    
                    // 🚀 DOBLE CANDADO: Filtramos el refresco post-pago de forma limpia
                    let freshItems = response.items ?? []
                    self.pendingInvoices = freshItems.filter { ($0.status ?? "").lowercased() == "pending" }
                }
                completion(true)
            }
        }
    }
}
