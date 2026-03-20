import Foundation

protocol Card_DataBaseRepositoryProtocol {
    func fetchAll(userId: String) async throws -> [Card]
    func fetchAllBy(userId: String, listId: String) async throws -> [Card]
    func add(userId: String, listId: String, card: AddCardRequest) async throws -> Card
    func update(userId: String, listId: String, card: UpdateCardRequest) async throws -> Card
    func delete(userId: String, listId: String, id: String) async throws
}

final class Card_DataBaseRepository: Card_DataBaseRepositoryProtocol {
    
    
    // MARK: - Private Helpers

    // URL定義
    let urlBuilder = URLBuilder()
    
    // MARK: - Public CRUD Functions
    
    // 全てを取得
    func fetchAll(userId: String) async throws -> [Card] {
        let url = try urlBuilder.makeURL(
            path: "cards",
            queryItems: [
                URLQueryItem(name: "userId", value: userId),
            ]
        )
        let data = try await sendRequest(url: url, method: "GET")
        return try decoder.decode([Card].self, from: data)
    }
    
    // 同期
    func fetchAllBy(userId: String, listId: String) async throws -> [Card] {
        let url = try urlBuilder.makeURL(
            path: "cards",
            queryItems: [
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "listId", value: listId)
            ]
        )
        let data = try await sendRequest(url: url, method: "GET")
        return try decoder.decode([Card].self, from: data)
    }
    
    // 追加
    func add(userId: String, listId: String, card: AddCardRequest ) async throws -> Card{
        let url = try urlBuilder.makeURL(
            path: "cards",
            queryItems: [
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "listId", value: listId),
            ]
        )
        let body = try encoder.encode(card)
        let data = try await sendRequest(url: url, method: "POST", body: body)
        return try decoder.decode(Card.self, from: data)
    }
    
    // 更新
    func update(userId: String, listId: String, card: UpdateCardRequest) async throws -> Card {
        let url = try urlBuilder.makeURL(
            path: "cards",
            queryItems: [
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "listId", value: listId),
                URLQueryItem(name: "cardId", value: card.id)
            ]
        )
        let body = try encoder.encode(card)
        let data = try await sendRequest(url: url, method: "PUT", body: body)
        return try decoder.decode(Card.self, from: data)
    }
    
    // 削除
    func delete(userId: String, listId: String, id: String) async throws {
        let url = try urlBuilder.makeURL(
            path: "cards",
            queryItems: [
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "listId", value: listId),
                URLQueryItem(name: "cardId", value: id)
            ]
        )
        _ = try await sendRequest(url: url, method: "DELETE")
    }
}

