import Foundation

protocol Card_DataBaseRepositoryProtocol {
    func fetch(listId: String) async throws -> [Card_ST]
    func add(card: AddCardRequest) async throws
    func update(list: UpdateCardRequest) async throws
    func delete(id: String) async throws
}

final class Card_DataBaseRepository: Card_DataBaseRepositoryProtocol {
    
    //URL定義
    private let session: UserSession
    let urlBuilder = URLBuilder()
    init(session: UserSession) {
        self.session = session
    }
    
    //同期
    func fetch(listId: String) async throws -> [Card_ST] {
        let url = try urlBuilder.makeURL(
            path: "cards",
            queryItems: [
                URLQueryItem(name: "userId", value: session.userId),
                URLQueryItem(name: "listId", value: listId)
            ]
        )
        let data = try await sendRequest(url: url, method: "GET")
        return try decoder.decode([Card_ST].self, from: data)
    }
    
    //追加
    func add(id: String, card: AddCardRequest) async throws -> Card_ST {
        let url = try urlBuilder.makeURL(
            path: "cards",
            queryItems: [
                URLQueryItem(name: "userId", value: session.userId),
                URLQueryItem(name: "listId", value: id),
            ]
        )
        let body = try encoder.encode(card)
        let data = try await sendRequest(url: url, method: "POST", body: body)
        return try decoder.decode(Card_ST.self, from: data)
    }
    
    //削除
    func delete(id: String) async throws {
        let url = try urlBuilder.makeURL(
            path: "users",
            queryItems: [
                URLQueryItem(name: "userId", value: session.userId),
                URLQueryItem(name: "listId", value: id)
            ]
        )
        _ = try await sendRequest(url: url, method: "DELETE")
    }
    
    func updateCardAPI(
        listId: String,
        cardId: String,
        card: 
    ) async {
        guard let url = URL(
            string: urlsession + "cards?userId=\(self.userid)&listId=\(listId)&cardId=\(cardId)"
        ) else {
            print("URLエラーっピ")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //Content-Typeでapplication/jsonを指定している
        let body: [String: Any] = [
            "id": cardId,
            "listid": listId,
            "en": en,
            "jp": jp,
            "createdAt": ISO8601DateFormatter().string(from: createdAt)
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("JSON変換エラーっピ: \(error)")
            return
        }

        do {
            _ = try await URLSession.shared.data(for: request)
            // 🔁 更新後は一覧を再取得
            await fetchCards(listId: listId)
        } catch {
            print("通信エラーっピ: \(error)")
        }
    }
}

