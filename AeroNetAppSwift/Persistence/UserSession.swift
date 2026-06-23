import Foundation
import CoreData

// MARK: - CoreData: Persistir sesión del usuario
@objc(UserSession)
public class UserSession: NSManagedObject {
    @NSManaged public var token: String
    @NSManaged public var email: String
    @NSManaged public var role: String
    @NSManaged public var userId: String
    @NSManaged public var loginDate: Date
    
    convenience init(token: String, email: String, role: String, userId: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "UserSession", in: context)!
        self.init(entity: entity, insertInto: context)
        self.token = token
        self.email = email
        self.role = role
        self.userId = userId
        self.loginDate = Date()
    }
}
