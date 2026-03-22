import Foundation
import CoreData

protocol Card_CoreDataRepositoryProtocol {
    func fetchAll() throws -> [Card]
    func fetchAllBy(listId: String) throws -> [Card]
    func saveAll(cards: [Card]) throws
    func update(card: Card) throws
    func add(card: Card) throws
    func delete(id: String) throws
}

class Card_CoreDataRepository: Card_CoreDataRepositoryProtocol {
    
    // MARK: - Private Helpers
    
    // 全てを取得
    private func currentEntities() throws -> [CardEntity] {
        let request = CoreDataRequest()
        return try request.fetchAll(ofType: CardEntity.self)
    }

    // Structに変換
    private func convertEntitiesToStructs(entities: [CardEntity]) throws -> [Card] {
        var cards: [Card] = []
        for entity in entities {
            guard
                let id = entity.id,
                let listId = entity.listId,
                let en = entity.en,
                let jp = entity.jp,
                let createdAt = entity.createdAt
            else {
                throw CoreDataError.inconsistentCardData
            }
            let order = Int(entity.order)
            let mistake = entity.mistake
            cards.append(Card(id: id, listId: listId, en: en, jp: jp, createdAt: createdAt, order: order, mistake: mistake))
        }
        return cards
    }
    
    // Entityに変換
    private func convertStructsToEntities(cards: [Card]) throws {
        for card in cards {
            let entity = CardEntity(context: context)
            entity.id = card.id
            entity.listId = card.listId
            entity.en = card.en
            entity.jp = card.jp
            entity.createdAt = card.createdAt
            entity.order = Int16(card.order)
            entity.mistake = card.mistake
        }
    }
    
    // id専用
    private func fetchById(by id: String) throws -> CardEntity? {
        let request = CoreDataRequest()
        return try request.fetchFirstBy(ofType: CardEntity.self, key: "id", value: id)
    }
    
    // listId専用
    private func fetchByListId(by listId: String) throws -> [CardEntity] {
        let request = CoreDataRequest()
        return try request.fetchAllBy(ofType: CardEntity.self, key: "listId", value: listId)
    }
    
    // MARK: - Public CRUD Functions
    
    // 全部取得
    func fetchAll() throws -> [Card] {
        let entities = try currentEntities()
        return try convertEntitiesToStructs(entities: entities)
    }
    
    // 指定リストのみ取得
    func fetchAllBy(listId: String) throws -> [Card] {
        let entities = try fetchByListId(by: listId)
        return try convertEntitiesToStructs(entities: entities)
    }
    
    // 保存
    func saveAll(cards: [Card]) throws {
        do {
            let oldEntities = try currentEntities()
            oldEntities.forEach { context.delete($0) }
            try convertStructsToEntities(cards: cards)
            try context.save()
        } catch {
            context.rollback()
            throw CoreDataError.saveFailed
        }
    }
    
    // 更新
    func update(card: Card) throws {
        do {
                guard let entity = try fetchById(by: card.id) else {
                    throw CoreDataError.inconsistentCardData
                }
                entity.en = card.en
                entity.jp = card.jp
                try context.save()
            } catch {
                context.rollback()
                throw CoreDataError.saveFailed
            }
    }
    
    // 追加
    func add(card: Card) throws {
        do {
            if try fetchById(by: card.id) != nil {
                throw CoreDataError.inconsistentCardData
            }
            try convertStructsToEntities(cards: [card])
            try context.save()
        } catch {
            context.rollback()
            throw CoreDataError.saveFailed
        }
        
    }
    
    // 削除
    func delete(id: String) throws {
        do {
            guard let entity = try fetchById(by: id) else {
                throw CoreDataError.inconsistentCardData
            }
            context.delete(entity)
            try context.save()
        } catch {
            context.rollback()
            throw CoreDataError.deleteFailed
        }
    }
}
