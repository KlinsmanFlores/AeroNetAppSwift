import Foundation
import SwiftUI

class InvoicesViewModel: ObservableObject {
    @Published var invoices: [Invoice] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    // Estados para el visor de documentos en la interfaz
    @Published var activeWebUrl: URL? = nil
    @Published var activeDocTitle: String = "Comprobante"
    @Published var showDocViewer = false
    
    // Diccionario dinámico para indexar los documentos encontrados por cada Invoice ID
    @Published var electronicDocuments: [String: ElectronicDocumentModel] = [:]
    
    func fetchInvoices() {
        self.isLoading = true
        self.errorMessage = nil
        self.successMessage = nil
        
        DispatchQueue.main.async {
            self.electronicDocuments.removeAll()
        }
        
        InvoiceService.shared.fetchAll { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    self.invoices = fetched
                    
                    // Fetch documents for paid invoices
                    for invoice in fetched {
                        let status = invoice.status?.lowercased() ?? ""
                        if status == "paid" || status == "invoiced" {
                            self.fetchDocumentForInvoice(invoiceId: invoice.id)
                        }
                    }
                case .failure(let error):
                    self.errorMessage = "Error al obtener facturas: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
    
    func generateMonthlyInvoices(period: String, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        self.errorMessage = nil
        self.successMessage = nil
        InvoiceService.shared.generateMonthly(period: period) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.successMessage = "Facturas generadas: \(response.count ?? 0). \(response.message ?? "")"
                    self.fetchInvoices()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al generar facturas: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
    
    func forceBillingInvoices(completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        self.errorMessage = nil
        self.successMessage = nil
        InvoiceService.shared.forceBilling { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.successMessage = "Facturación forzada completada: \(response.count ?? 0). \(response.message ?? "")"
                    self.fetchInvoices()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al forzar facturación: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
    
    func deleteInvoice(id: String, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        self.errorMessage = nil
        InvoiceService.shared.delete(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.fetchInvoices()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al eliminar factura: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
    
    private func fetchDocumentForInvoice(invoiceId: String) {
        let endpoint = "/electronic-documents/invoice/\(invoiceId)"
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
                let documentsArray = try JSONDecoder().decode([ElectronicDocumentModel].self, from: data)
                DispatchQueue.main.async {
                    if let firstDoc = documentsArray.first {
                        self.electronicDocuments[invoiceId] = firstDoc
                    }
                }
            } catch {
                print("DECODING ERROR en sub-consulta: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func abrirEnNavegador(urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
