import Foundation
import CoreData

protocol List_CoreDataRepositoryProtocol {
    func fetch() throws -> [List_ST]
    func saveAll(lists: [List_ST]) throws
    func add(list: List_ST) throws
    func delete(id: String) throws
}

class List_CoreDataRepository: List_CoreDataRepositoryProtocol {
    
    //コアデータ読み込みStructを読み込み
    private func currentEntity() throws -> [ListEntity] {
        let request = CoreDataRequest()
        return try request.fetchAll(ofType: ListEntity.self)
    }
    
    //チェックと変換作業
    private func checkConvertEntity(entities: [ListEntity]) throws -> [List_ST] {
        var lists: [List_ST] = []
        for entity in entities {
            guard
                let id = entity.id,
                let title = entity.title,
                let createdAt = entity.createdAt
            else {
                throw CDError.inconsistentListData
            }
            lists.append(List_ST(id: id, title: title, createdAt: createdAt))
        }
        return lists
    }
    
    //同期
    func fetch() throws -> [List_ST] {
        let entities = try currentEntity()
        return try checkConvertEntity(entities: entities)
    }
    
    //保存
    func saveAll(lists: [List_ST]) throws {
        do {
            let oldEntities = try currentEntity()
            oldEntities.forEach { context.delete($0) }
            for list in lists {
                let entity = ListEntity(context: context)
                entity.id = list.id
                entity.title = list.title
                entity.createdAt = list.createdAt
            }
            try context.save()
        } catch {
            context.rollback()
            throw CDError.saveFailed
        }
    }
    
    //追加
    func add(list: List_ST) throws {
        do {
            let entity = ListEntity(context: context)
            entity.id = list.id
            entity.title = list.title
            entity.createdAt = list.createdAt
            try context.save()
        } catch {
            context.rollback()
            throw CDError.saveFailed
        }
        
    }
    
    //削除
    func delete(id: String) throws {
        do {
            let entities = try currentEntity()
            guard let entity = entities.first(where: {$0.id == id}) else {
                throw CDError.inconsistentListData
            }
            context.delete(entity)
            try context.save()
        } catch {
            context.rollback()
            throw CDError.deleteFailed
        }
    }
}
