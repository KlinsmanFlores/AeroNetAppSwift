import Foundation
import SwiftUI
import CoreData
@MainActor
class ClientPlansViewModel: ObservableObject {
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
            errorMessage = "Error al obtener catálogo de planes: \(error.localizedDescription)"
            
            // Cargar de cache si falla (Semana 11 offline)
            let context = CoreDataManager.shared.viewContext
            let fetchRequest: NSFetchRequest<CachedPlan> = NSFetchRequest(entityName: "CachedPlan")
            if let cached = try? context.fetch(fetchRequest), !cached.isEmpty {
                self.plans = cached.map { $0.toPlan() }
                errorMessage = "Cargado desde el modo offline (sin conexión)."
            }
        }
        isLoading = false
    }
}
