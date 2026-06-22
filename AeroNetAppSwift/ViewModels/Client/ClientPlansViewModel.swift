import Foundation
import SwiftUI
import SwiftData

@MainActor
class ClientPlansViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchPlans(modelContext: ModelContext? = nil) async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedPlans = try await PlanService.shared.fetchAll()
            self.plans = fetchedPlans
            
            // Guardar en cache SwiftData (Semana 11)
            if let context = modelContext {
                let fetchDescriptor = FetchDescriptor<CachedPlan>()
                if let oldCached = try? context.fetch(fetchDescriptor) {
                    for plan in oldCached {
                        context.delete(plan)
                    }
                }
                for plan in fetchedPlans {
                    let cached = CachedPlan(from: plan)
                    context.insert(cached)
                }
                try? context.save()
            }
        } catch {
            errorMessage = "Error al obtener catálogo de planes: \(error.localizedDescription)"
            
            // Cargar de cache si falla (Semana 11 offline)
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
}
