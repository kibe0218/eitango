import Foundation
import CoreData

let context: NSManagedObjectContext = PersistenceController.shared.container.viewContext

struct CoreDataRequest {
    
    // 1つだけ
    func fetchSingle<T: NSManagedObject>(ofType type: T.Type) throws -> T? {
        let request: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        let entities = try context.fetch(request)
        if entities.count > 1 {
            throw CDError.inconsistentUserData
        }
        return entities.first
    }
    
    // 全部
    func fetchAll<T: NSManagedObject>(ofType type: T.Type) throws -> [T] {
        let request: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        return try context.fetch(request)
    }
    
    // 条件に合う一つだけ
    func fetchFirstBy<T: NSManagedObject, Value: CVarArg>(
        ofType type: T.Type,
        key: String,
        value: Value
    ) throws -> T? {
        let request: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "\(key) == %@", value)
        let results = try context.fetch(request)
        return results.first
    }
    
    // 条件に合う全部
    func fetchAllBy<T: NSManagedObject, Value: CVarArg>(
        ofType type: T.Type,
        key: String,
        value: Value
    ) throws -> [T] {
        let request: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        request.predicate = NSPredicate(format: "\(key) == %@", value)
        return try context.fetch(request)
    }
}
