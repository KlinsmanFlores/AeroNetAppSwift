import Foundation
import CoreData

// MARK: - CoreData: Cachear planes para acceso offline
@objc(CachedPlan)
public class CachedPlan: NSManagedObject {
    @NSManaged public var planId: String
    @NSManaged public var name: String
    @NSManaged public var price: Double
    @NSManaged public var speedMbps: Double
    @NSManaged public var planDescription: String
    @NSManaged public var cachedDate: Date
    
    convenience init(from plan: Plan, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "CachedPlan", in: context)!
        self.init(entity: entity, insertInto: context)
        self.planId = plan.id
        self.name = plan.name ?? ""
        self.price = plan.price ?? 0
        self.speedMbps = plan.speed_mbps ?? 0
        self.planDescription = plan.description ?? ""
        self.cachedDate = Date()
    }
    
    func toPlan() -> Plan {
        return Plan(
            id: planId,
            name: name,
            price: price,
            speed_mbps: speedMbps,
            description: planDescription,
            status: "active",
            created_at: nil
        )
    }
}

// MARK: - CoreData Manager (Inline to avoid pbxproj modifications)
class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        let model = NSManagedObjectModel()
        
        let planEntity = NSEntityDescription()
        planEntity.name = "CachedPlan"
        planEntity.managedObjectClassName = NSStringFromClass(CachedPlan.self)
        
        let idAttr = NSAttributeDescription()
        idAttr.name = "planId"
        idAttr.attributeType = .stringAttributeType
        idAttr.isOptional = false
        
        let nameAttr = NSAttributeDescription()
        nameAttr.name = "name"
        nameAttr.attributeType = .stringAttributeType
        nameAttr.isOptional = false
        
        let priceAttr = NSAttributeDescription()
        priceAttr.name = "price"
        priceAttr.attributeType = .doubleAttributeType
        priceAttr.isOptional = false
        
        let speedAttr = NSAttributeDescription()
        speedAttr.name = "speedMbps"
        speedAttr.attributeType = .doubleAttributeType
        speedAttr.isOptional = false
        
        let descAttr = NSAttributeDescription()
        descAttr.name = "planDescription"
        descAttr.attributeType = .stringAttributeType
        descAttr.isOptional = false
        
        let dateAttr = NSAttributeDescription()
        dateAttr.name = "cachedDate"
        dateAttr.attributeType = .dateAttributeType
        dateAttr.isOptional = false
        
        planEntity.properties = [idAttr, nameAttr, priceAttr, speedAttr, descAttr, dateAttr]
        
        let userEntity = NSEntityDescription()
        userEntity.name = "UserSession"
        userEntity.managedObjectClassName = NSStringFromClass(UserSession.self)
        
        let tokenAttr = NSAttributeDescription()
        tokenAttr.name = "token"
        tokenAttr.attributeType = .stringAttributeType
        
        let emailAttr = NSAttributeDescription()
        emailAttr.name = "email"
        emailAttr.attributeType = .stringAttributeType
        
        let roleAttr = NSAttributeDescription()
        roleAttr.name = "role"
        roleAttr.attributeType = .stringAttributeType
        
        let userIdAttr = NSAttributeDescription()
        userIdAttr.name = "userId"
        userIdAttr.attributeType = .stringAttributeType
        
        let loginAttr = NSAttributeDescription()
        loginAttr.name = "loginDate"
        loginAttr.attributeType = .dateAttributeType
        
        userEntity.properties = [tokenAttr, emailAttr, roleAttr, userIdAttr, loginAttr]
        
        model.entities = [planEntity, userEntity]
        
        container = NSPersistentContainer(name: "AeroNetModel", managedObjectModel: model)
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
}
