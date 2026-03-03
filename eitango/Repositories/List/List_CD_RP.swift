import Foundation
import CoreData

protocol List_CoreDataRepositoryProtocol {
    func fetchAll() throws -> [List_ST]
    func saveAll(lists: [List_ST]) throws
    func add(list: List_ST) throws
    func delete(id: String) throws
}

class List_CoreDataRepository: List_CoreDataRepositoryProtocol {
    
    //コアデータ読み込みStructを読み込み
    private func currentEntities() throws -> [ListEntity] {
        let request = CoreDataRequest()
        return try request.fetchAll(ofType: ListEntity.self)
    }
    
    //Structに変換
    private func convertEntitiesToStructs(entities: [ListEntity]) throws -> [List_ST] {
        var lists: [List_ST] = []
        for entity in entities {
            guard
                let id = entity.id,
                let title = entity.title,
                let createdAt = entity.createdAt
            else {
                throw CDError.inconsistentListData
            }
            let cardCount = Int(entity.cardCount)
            lists.append(List_ST(id: id, title: title, createdAt: createdAt, cardCount: cardCount))
        }
        return lists
    }
    
    //Entityに変換
    private func convertStructsToEntities(lists: [List_ST]) throws {
        for list in lists {
            let entity = ListEntity(context: context)
            entity.id = list.id
            entity.title = list.title
            entity.createdAt = list.createdAt
            entity.cardCount = Int16(list.cardCount)
        }
    }
        
    //同期
    func fetchAll() throws -> [List_ST] {
        let entities = try currentEntities()
        return try convertEntitiesToStructs(entities: entities)
    }
    
    //保存
    func saveAll(lists: [List_ST]) throws {
        do {
            let oldEntities = try currentEntities()
            oldEntities.forEach { context.delete($0) }
            try convertStructsToEntities(lists: lists)
            try context.save()
        } catch {
            context.rollback()
            throw CDError.saveFailed
        }
    }
    
    //追加
    func add(list: List_ST) throws {
        do {
            try convertStructsToEntities(lists: [list])
            try context.save()
        } catch {
            context.rollback()
            throw CDError.saveFailed
        }
        
    }
    
    //削除
    func delete(id: String) throws {
        do {
            let entities = try currentEntities()
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
