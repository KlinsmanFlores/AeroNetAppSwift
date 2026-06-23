import Foundation
import SwiftUI
import CoreData

class PlansViewModel: ObservableObject {
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
                    self.errorMessage = "Error al obtener planes: \(error.localizedDescription)"
                    
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
    
    func createPlan(name: String, price: Double, speedMbps: Double, description: String, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        self.errorMessage = nil
        let data: [String: Any] = [
            "name": name,
            "price": price,
            "speed_mbps": speedMbps,
            "description": description,
            "status": "active"
        ]
        PlanService.shared.create(data) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.fetchPlans()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al crear plan: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
    
    func deletePlan(id: String, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        self.errorMessage = nil
        PlanService.shared.delete(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.fetchPlans()
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Error al eliminar plan: \(error.localizedDescription)"
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
}
