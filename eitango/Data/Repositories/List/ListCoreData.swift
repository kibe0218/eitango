import Foundation
import CoreData

protocol List_CoreDataRepositoryProtocol {
    func fetchAll() throws -> [CardList]
    func saveAll(lists: [CardList]) throws
    func add(list: CardList) throws
    func delete(id: String) throws
}

class List_CoreDataRepository: List_CoreDataRepositoryProtocol {
     
    // MARK: - Private Helpers
    
    // コアデータ読み込みStructを読み込み
    private func currentEntities() throws -> [ListEntity] {
        let request = CoreDataRequest()
        return try request.fetchAll(ofType: ListEntity.self)
    }
    
    // Structに変換
    private func convertEntitiesToStructs(entities: [ListEntity]) throws -> [CardList] {
        var lists: [CardList] = []
        for entity in entities {
            guard
                let id = entity.id,
                let title = entity.title,
                let createdAt = entity.createdAt
            else {
                throw CoreDataError.inconsistentListData
            }
            let cardCount = Int(entity.cardCount)
            lists.append(CardList(id: id, title: title, createdAt: createdAt, cardCount: cardCount))
        }
        return lists
    }
    
    // Entityに変換
    private func convertStructsToEntities(lists: [CardList]) throws {
        for list in lists {
            let entity = ListEntity(context: context)
            entity.id = list.id
            entity.title = list.title
            entity.createdAt = list.createdAt
            entity.cardCount = Int16(list.cardCount)
        }
    }
        
    // MARK: - Public CRUD Functions
    
    // 同期
    func fetchAll() throws -> [CardList] {
        let entities = try currentEntities()
        return try convertEntitiesToStructs(entities: entities)
    }
    
    // 保存
    func saveAll(lists: [CardList]) throws {
        do {
            let oldEntities = try currentEntities()
            oldEntities.forEach { context.delete($0) }
            try convertStructsToEntities(lists: lists)
            try context.save()
        } catch {
            context.rollback()
            throw CoreDataError.saveFailed
        }
    }
    
    // 追加
    func add(list: CardList) throws {
        do {
            try convertStructsToEntities(lists: [list])
            try context.save()
        } catch {
            context.rollback()
            throw CoreDataError.saveFailed
        }
        
    }
    
    // 削除
    func delete(id: String) throws {
        do {
            let entities = try currentEntities()
            guard let entity = entities.first(where: {$0.id == id}) else {
                throw CoreDataError.inconsistentListData
            }
            context.delete(entity)
            try context.save()
        } catch {
            context.rollback()
            throw CoreDataError.deleteFailed
        }
    }
    
    
}
