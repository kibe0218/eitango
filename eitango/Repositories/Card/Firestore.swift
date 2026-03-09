import Foundation

protocol Card_DataBaseRepositoryProtocol {
    func fetchAll() async throws -> [Card]
    func fetchAllBy(listId: String) async throws -> [Card]
    func add(listId: String, card: AddCardRequest) async throws -> Card
    func update(listId: String, card: UpdateCardRequest) async throws -> Card
    func delete(listId: String, id: String) async throws
}

final class Card_DataBaseRepository: Card_DataBaseRepositoryProtocol {
    
    
    // MARK: - Private Helpers

    // URL定義
    private let session: UserSession
    let urlBuilder = URLBuilder()
    init(session: UserSession) {
        self.session = session
    }
    
    // MARK: - Public CRUD Functions
    
    // 全てを取得
    func fetchAll() async throws -> [Card] {
        let url = try urlBuilder.makeURL(
            path: "cards",
            queryItems: [
                URLQueryItem(name: "userId", value: session.userId),
            ]
        )
        let data = try await sendRequest(url: url, method: "GET")
        return try decoder.decode([Card].self, from: data)
    }
    // 同期
    func fetchAllBy(listId: String) async throws -> [Card] {
        let url = try urlBuilder.makeURL(
            path: "cards",
            queryItems: [
                URLQueryItem(name: "userId", value: session.userId),
                URLQueryItem(name: "listId", value: listId)
            ]
        )
        let data = try await sendRequest(url: url, method: "GET")
        return try decoder.decode([Card].self, from: data)
    }
    
    // 追加
    func add(listId: String, card: AddCardRequest) async throws -> Card{
        let url = try urlBuilder.makeURL(
            path: "cards",
            queryItems: [
                URLQueryItem(name: "userId", value: session.userId),
                URLQueryItem(name: "listId", value: listId),
            ]
        )
        let body = try encoder.encode(card)
        let data = try await sendRequest(url: url, method: "POST", body: body)
        return try decoder.decode(Card.self, from: data)
    }
    
    // 更新
    func update(listId: String, card: UpdateCardRequest) async throws -> Card {
        let url = try urlBuilder.makeURL(
            path: "cards",
            queryItems: [
                URLQueryItem(name: "userId", value: session.userId),
                URLQueryItem(name: "listId", value: listId),
                URLQueryItem(name: "cardId", value: card.id)
            ]
        )
        let body = try encoder.encode(card)
        let data = try await sendRequest(url: url, method: "PUT", body: body)
        return try decoder.decode(Card.self, from: data)
    }
    
    // 削除
    func delete(listId: String, id: String) async throws {
        let url = try urlBuilder.makeURL(
            path: "cards",
            queryItems: [
                URLQueryItem(name: "userId", value: session.userId),
                URLQueryItem(name: "listId", value: listId),
                URLQueryItem(name: "cardId", value: id)
            ]
        )
        _ = try await sendRequest(url: url, method: "DELETE")
    }
}

