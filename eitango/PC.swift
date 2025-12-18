import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    // NSPersistentContainer に変更
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "eitangoData")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // ストアを読み込む
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // 他デバイスでの変更を自動マージ
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // 競合時はプロパティ側を優先
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
