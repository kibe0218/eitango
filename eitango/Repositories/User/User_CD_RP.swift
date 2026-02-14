import Foundation
import CoreData

protocol CoreDataRepositoryProtocol {
    func fetch_User_CD() throws -> User_ST?
    func add_User_CD(user: User_ST) throws
    func delete_User_CD() throws
}

class CoreDataRepository: CoreDataRepositoryProtocol {
    
    //コンテキストを定義
    private var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    //取得作業
    private func currentUserEntity() throws -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        let entity = try context.fetch(request)
        if entity.count > 1 {
            throw CDError.inconsistentUserData
        }
        return entity.first
    }
    
    //チェック作業
    private func checkEntity(entity: UserEntity) throws -> User_ST {
        guard
            let id = entity.id,
            let name = entity.name,
            let createdAt = entity.createdAt
        else {
            throw CDError.inconsistentUserData
        }
        return User_ST(id: id, name: name, createdAt: createdAt)
    }
    
    //同期
    func fetch_User_CD() throws -> User_ST? {
        guard let entity = try currentUserEntity() else {
            return nil
        }
        return try checkEntity(entity: entity)
    }
    
    //追加
    func add_User_CD(user: User_ST) throws {
        do {
            if let olduser = try currentUserEntity() {
                context.delete(olduser)
            }
            let entity = UserEntity(context: context)
            entity.id = user.id
            entity.name = user.name
            entity.createdAt = user.createdAt
            try context.save()
        } catch {
            context.rollback()
            throw CDError.saveFailed
        }
        
    }
    
    //削除
    func delete_User_CD() throws {
        do {
            if let olduser = try currentUserEntity() {
                context.delete(olduser)
            }
            try context.save()
        } catch {
            context.rollback()
            throw CDError.deleteFailed
        }
    }
}
