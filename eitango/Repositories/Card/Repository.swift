import Foundation
import Combine

protocol CardRepositoryProtocol {
    func fetchAll() throws -> [Card]
    func fetchAllBy(listId: String) throws -> [Card]
    func reload() async throws -> [Card]
    func add(listId: String, card: AddCardRequest) async throws -> Card
    func update(listId: String, card: UpdateCardRequest) async throws -> Card
    func delete(listId: String, id: String) async throws
}

class C
ardRepository: CardRepositoryProtocol {
    
    let dbRepository: Card_DataBaseRepositoryProtocol
    let cdRepository: Card_CoreDataRepositoryProtocol
    init (
        card_dbRepository: Card_DataBaseRepositoryProtocol,
        card_cdRepository: Card_CoreDataRepositoryProtocol,
    ) throws {
        self.dbRepository = card_dbRepository
        self.cdRepository = card_cdRepository
    }
    
    // MARK: - Public CRUD Functions

    
    // CoreDataから全部とってくる
    func fetchAll() throws -> [Card] {
        return try cdRepository.fetchAll()
    }
    
    // listIdのものだけCoreDataから取ってくる
    func fetchAllBy(listId: String) throws -> [Card] {
        return try cdRepository.fetchAllBy(listId: listId)
    }
    
    // DB基準で再読み込み
    func reload() async throws -> [Card] {
        let cards = try await dbRepository.fetchAll()
        try cdRepository.saveAll(cards: cards)
        return cards
    }
    
    // 追加
    func add(listId: String, card: AddCardRequest) async throws -> Card {
        let card = try await dbRepository.add(listId: listId, card: card)
        guard !card.id.isEmpty else { throw AuthError.unknown }
        _ = try cdRepository.add(card: card)
        return card
    }
    
    // 更新
    func update(listId: String, card: UpdateCardRequest) async throws -> Card {
        let card  = try await dbRepository.update(listId: listId, card: card)
        try cdRepository.update(card: card)
        return card
    }
    
    // 削除
    func delete(listId: String, id: String) async throws {
        try await dbRepository.delete(listId: listId, id: id)
        try cdRepository.delete(id: id)
    }
}
