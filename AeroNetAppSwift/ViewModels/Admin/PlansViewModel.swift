import Foundation
import SwiftUI
import SwiftData

@MainActor
class PlansViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchPlans(modelContext: ModelContext? = nil) async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedPlans = try await PlanService.shared.fetchAll()
            self.plans = fetchedPlans
            
            // Si hay un modelContext, guardar en cache SwiftData (Semana 11)
            if let context = modelContext {
                // Limpiar cache vieja
                let fetchDescriptor = FetchDescriptor<CachedPlan>()
                if let oldCached = try? context.fetch(fetchDescriptor) {
                    for plan in oldCached {
                        context.delete(plan)
                    }
                }
                
                // Insertar nuevos
                for plan in fetchedPlans {
                    let cached = CachedPlan(from: plan)
                    context.insert(cached)
                }
                try? context.save()
            }
        } catch {
            errorMessage = "Error al obtener planes: \(error.localizedDescription)"
            
            // Cargar de cache si falla la red (Semana 11 offline)
            if let context = modelContext {
                let fetchDescriptor = FetchDescriptor<CachedPlan>()
                if let cached = try? context.fetch(fetchDescriptor), !cached.isEmpty {
                    self.plans = cached.map { $0.toPlan() }
                    errorMessage = "Cargado desde el modo offline (sin conexión)."
                }
            }
        }
        isLoading = false
    }
    
    func createPlan(name: String, price: Double, speedMbps: Double, description: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        let data: [String: Any] = [
            "name": name,
            "price": price,
            "speed_mbps": speedMbps,
            "description": description,
            "status": "active"
        ]
        do {
            _ = try await PlanService.shared.create(data)
            await fetchPlans()
            isLoading = false
            return true
        } catch {
            errorMessage = "Error al crear plan: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func deletePlan(id: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            try await PlanService.shared.delete(id: id)
            await fetchPlans()
            isLoading = false
            return true
        } catch {
            errorMessage = "Error al eliminar plan: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
}
