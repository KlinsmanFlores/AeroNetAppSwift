import Foundation
import SwiftUI

class ClientInvoicesViewModel: ObservableObject {
    @Published var invoices: [Invoice] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // Estados para el visor de documentos en la interfaz
    @Published var activeWebUrl: URL? = nil
    @Published var activeDocTitle: String = "Comprobante"
    @Published var showDocViewer = false
    
    // Diccionario dinámico para indexar los documentos encontrados por cada Invoice ID
    @Published var electronicDocuments: [String: ElectronicDocumentModel] = [:]

    func fetchInvoices() {
        self.isLoading = true
        self.errorMessage = nil
        
        // 🚀 LIMPIEZA DE SEGURIDAD: Vacía estados previos antes de repintar la lista
        DispatchQueue.main.async {
            self.electronicDocuments.removeAll()
        }
        
        InvoiceService.shared.fetchMyDebts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let items = response.items ?? []
                    self.invoices = items
                    
                    // JALE AUTOMÁTICO: Evaluamos tanto "paid" como "invoiced"
                    for invoice in items {
                        let status = invoice.status?.lowercased() ?? ""
                        if status == "paid" || status == "invoiced" {
                            self.fetchDocumentForInvoice(invoiceId: invoice.id)
                        }
                    }
                case .failure(let error):
                    self.errorMessage = "Error al obtener tus comprobantes: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
    
    // Función arreglada para consumir el formato Array [] de Render
    private func fetchDocumentForInvoice(invoiceId: String) {
        let endpoint = "/electronic-documents/invoice/\(invoiceId)"
        
        // Usamos tu NetworkManager nativo que ya tiene la URL base de Secrets.swift
        guard let baseUrl = URL(string: NetworkManager.shared.baseURL + endpoint) else { return }
        
        var request = URLRequest(url: baseUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                // CORRECCIÓN HISTÓRICA: Se parsea como Arreglo de objetos debido al formato de tu API
                let documentsArray = try JSONDecoder().decode([ElectronicDocumentModel].self, from: data)
                
                DispatchQueue.main.async {
                    // Si el servidor devolvió elementos en la lista, extraemos el primero de forma automatizada
                    if let firstDoc = documentsArray.first {
                        self.electronicDocuments[invoiceId] = firstDoc
                        print("✅ ÉXITO AUTOMÁTICO: Documento extraído del array para factura \(invoiceId)")
                    } else {
                        print("⚠️ INFO: El arreglo de documentos vino vacío para la factura \(invoiceId)")
                    }
                }
            } catch {
                print("❌ DECODING ERROR en sub-consulta: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func abrirEnNavegador(urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
