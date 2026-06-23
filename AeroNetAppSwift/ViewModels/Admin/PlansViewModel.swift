import Foundation
import SwiftUI
import CoreData
@MainActor
class PlansViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchPlans() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedPlans = try await PlanService.shared.fetchAll()
            self.plans = fetchedPlans
            
            // Guardar en cache Core Data (Semana 11)
            let context = CoreDataManager.shared.viewContext
            let fetchRequest: NSFetchRequest<CachedPlan> = NSFetchRequest(entityName: "CachedPlan")
            if let oldCached = try? context.fetch(fetchRequest) {
                for plan in oldCached {
                    context.delete(plan)
                }
            }
            
            for plan in fetchedPlans {
                _ = CachedPlan(from: plan, context: context)
            }
            try? context.save()
            
        } catch {
            errorMessage = "Error al obtener planes: \(error.localizedDescription)"
            
            // Cargar de cache si falla la red (Semana 11 offline)
            let context = CoreDataManager.shared.viewContext
            let fetchRequest: NSFetchRequest<CachedPlan> = NSFetchRequest(entityName: "CachedPlan")
            if let cached = try? context.fetch(fetchRequest), !cached.isEmpty {
                self.plans = cached.map { $0.toPlan() }
                errorMessage = "Cargado desde el modo offline (sin conexión)."
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
