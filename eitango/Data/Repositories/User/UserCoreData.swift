import Foundation
import CoreData

protocol User_CoreDataRepositoryProtocol {
    func fetch() throws -> User?
    func add(user: User) throws
    func delete() throws
}

class User_CoreDataRepository: User_CoreDataRepositoryProtocol {
    
    // MARK: - Private Helpers
    
    // コアデータ読み込みStructを読み込み
    private func currentEntity() throws -> UserEntity? {
        let request = CoreDataRequest()
        return try request.fetchSingle(ofType: UserEntity.self)
    }
    
    // Structに変換
    private func convertToStruct(entity: UserEntity) throws -> User {
        guard
            let id = entity.id,
            let name = entity.name,
            let createdAt = entity.createdAt
        else {
            throw CoreDataError.inconsistentUserData
        }
        return User(id: id, name: name, createdAt: createdAt)
    }
    
    // Entityに変換
    private func convertToEntity(user: User) throws {
        let entity = UserEntity(context: context)
        entity.id = user.id
        entity.name = user.name
        entity.createdAt = user.createdAt
    }
    
    // MARK: - Public CRUD Functions

    // 同期
    func fetch() throws -> User? {
        guard let entity = try currentEntity() else { return nil }
        return try convertToStruct(entity: entity)
    }
    
    // 追加
    func add(user: User) throws {
        do {
            if let olduser = try currentEntity() {
                context.delete(olduser)
            }
            try convertToEntity(user: user)
            try context.save()
        } catch {
            context.rollback()
            throw CoreDataError.saveFailed
        }
    }
    
    // 削除
    func delete() throws {
        do {
            if let olduser = try currentEntity() {
                context.delete(olduser)
            }
            try context.save()
        } catch {
            context.rollback()
            throw CoreDataError.deleteFailed
        }
    }
}
