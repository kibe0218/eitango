import Foundation
import CoreData

protocol Card_CoreDataRepositoryProtocol {
    func fetchAll() throws -> [Card_ST]
    func fetchAllBy(listId: String) throws -> [Card_ST]
    func saveAll(cards: [Card_ST]) throws
    func update(card: Card_ST) throws
    func add(card: Card_ST) throws
    func delete(id: String) throws
}

class Card_CoreDataRepository: Card_CoreDataRepositoryProtocol {
    
    //全てを
    private func currentEntities() throws -> [CardEntity] {
        let request = CoreDataRequest()
        return try request.fetchAll(ofType: CardEntity.self)
    }

    //Structに変換
    private func convertEntitiesToStructs(entities: [CardEntity]) throws -> [Card_ST] {
        var cards: [Card_ST] = []
        for entity in entities {
            guard
                let id = entity.id,
                let listId = entity.listId,
                let en = entity.en,
                let jp = entity.jp,
                let createdAt = entity.createdAt
            else {
                throw CDError.inconsistentCardData
            }
            let order = Int(entity.order)
            cards.append(Card_ST(id: id, listId: listId, en: en, jp: jp, createdAt: createdAt, order: order))
        }
        return cards
    }
    
    //Entityに変換
    private func convertStructsToEntities(cards: [Card_ST]) throws {
        for card in cards {
            let entity = CardEntity(context: context)
            entity.id = card.id
            entity.listId = card.listId
            entity.en = card.en
            entity.jp = card.jp
            entity.createdAt = card.createdAt
            entity.order = Int16(card.order)
        }
    }
    
    //id専用
    private func fetchById(by id: String) throws -> CardEntity? {
        let request = CoreDataRequest()
        return try request.fetchFirstBy(ofType: CardEntity.self, key: "id", value: id)
    }
    
    //listId専用
    private func fetchByListId(by listId: String) throws -> [CardEntity] {
        let request = CoreDataRequest()
        return try request.fetchAllBy(ofType: CardEntity.self, key: "listId", value: listId)
    }

//===========================================================================================
    
    //全部とる
    func fetchAll() throws -> [Card_ST] {
        let entities = try currentEntities()
        return try convertEntitiesToStructs(entities: entities)
    }
    
    //指定のリストのみ
    func fetchAllBy(listId: String) throws -> [Card_ST] {
        let entities = try fetchByListId(by: listId)
        return try convertEntitiesToStructs(entities: entities)
    }
    
    //保存
    func saveAll(cards: [Card_ST]) throws {
        do {
            let oldEntities = try currentEntities()
            oldEntities.forEach { context.delete($0) }
            try convertStructsToEntities(cards: cards)
            try context.save()
        } catch {
            context.rollback()
            throw CDError.saveFailed
        }
    }
    
    //更新
    func update(card: Card_ST) throws {
        do {
                guard let entity = try fetchById(by: card.id) else {
                    throw CDError.inconsistentCardData
                }
                entity.en = card.en
                entity.jp = card.jp
                try context.save()
            } catch {
                context.rollback()
                throw CDError.saveFailed
            }
    }
    
    //追加
    func add(card: Card_ST) throws {
        do {
            if try fetchById(by: card.id) != nil {
                throw CDError.inconsistentCardData
            }
            try convertStructsToEntities(cards: [card])
            try context.save()
        } catch {
            context.rollback()
            throw CDError.saveFailed
        }
        
    }
    
    //削除
    func delete(id: String) throws {
        do {
            guard let entity = try fetchById(by: id) else {
                throw CDError.inconsistentCardData
            }
            context.delete(entity)
            try context.save()
        } catch {
            context.rollback()
            throw CDError.deleteFailed
        }
    }
}
