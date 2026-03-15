import Foundation
import Combine

protocol CardRepositoryProtocol {
    func fetchAll() throws -> [Card]
    func fetchAllBy(listId: String) throws -> [Card]
    func reload(userId: String) async throws -> [Card]
    func addTranslated(userId: String, listId: String, source: String, target: String, sourceWord: String) async throws -> Card
    func add(userId: String, listId: String, card: AddCardRequest) async throws -> Card
    func update(userId: String, listId: String, card: UpdateCardRequest) async throws -> Card
    func delete(userId: String, listId: String, id: String) async throws
}

class CardRepository: CardRepositoryProtocol {
    
    let dbRepository: Card_DataBaseRepositoryProtocol
    let cdRepository: Card_CoreDataRepositoryProtocol
    let translateRepository: TranslateRepositoryProtocol
    init (
        card_dbRepository: Card_DataBaseRepositoryProtocol,
        card_cdRepository: Card_CoreDataRepositoryProtocol,
        card_translateRepository: TranslateRepositoryProtocol
    ) {
        self.dbRepository = card_dbRepository
        self.cdRepository = card_cdRepository
        self.translateRepository = card_translateRepository
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
    func reload(userId: String) async throws -> [Card] {
        let cards = try await dbRepository.fetchAll(userId: userId)
        try cdRepository.saveAll(cards: cards)
        return cards
    }
    
    //翻訳して追加
    func addTranslated(userId: String, listId: String, source: String, target: String, sourceWord: String) async throws -> Card {
        let translated = translateRepository.translateTextWithGAS(text: sourceWord, source: source, target: target)
        return try await add(userId: userId, listId: listId, card: AddCardRequest(en: source, jp: translated))
        // ↑逆もできるようにする
    }
    
    // 追加
    func add(userId: String, listId: String, card: AddCardRequest) async throws -> Card {
        let card = try await dbRepository.add(userId: userId, listId: listId, card: card)
        guard !card.id.isEmpty else { throw AuthError.unknown }
        _ = try cdRepository.add(card: card)
        return card
    }
    
    // 更新
    func update(userId: String, listId: String, card: UpdateCardRequest) async throws -> Card {
        let card  = try await dbRepository.update(userId: userId, listId: listId, card: card)
        try cdRepository.update(card: card)
        return card
    }
    
    // 削除
    func delete(userId: String, listId: String, id: String) async throws {
        try await dbRepository.delete(userId: userId, listId: listId, id: id)
        try cdRepository.delete(id: id)
    }
}
