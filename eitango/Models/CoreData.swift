import Foundation
import CoreData

let context: NSManagedObjectContext = PersistenceController.shared.container.viewContext

struct CoreDataRequest {
    
    func fetchOne<T: NSManagedObject>(ofType type: T.Type) throws -> T? {
        let request: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        let entities = try context.fetch(request)
        if entities.count > 1 {
            throw CDError.inconsistentUserData
        }
        return entities.first
    }

}
