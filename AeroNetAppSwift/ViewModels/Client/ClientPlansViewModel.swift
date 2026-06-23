import Foundation
import SwiftUI
import CoreData

class ClientPlansViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchPlans() {
        self.isLoading = true
        self.errorMessage = nil
        
        PlanService.shared.fetchAll { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedPlans):
                    self.plans = fetchedPlans
                    
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
                    
                case .failure(let error):
                    self.errorMessage = "Error al obtener catálogo de planes: \(error.localizedDescription)"
                    
                    let context = CoreDataManager.shared.viewContext
                    let fetchRequest: NSFetchRequest<CachedPlan> = NSFetchRequest(entityName: "CachedPlan")
                    if let cached = try? context.fetch(fetchRequest), !cached.isEmpty {
                        self.plans = cached.map { $0.toPlan() }
                        self.errorMessage = "Cargado desde el modo offline (sin conexión)."
                    }
                }
                self.isLoading = false
            }
        }
    }
}
