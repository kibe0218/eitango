import Foundation

protocol List_DataBaseRepositoryProtocol {
    func fetch() async throws -> [List]
    func add(list: AddListRequest) async throws -> List
    func delete(id: String) async throws
}

final class List_DataBaseRepository: List_DataBaseRepositoryProtocol {
    
    //URL定義
    private let session: UserSession
    let urlBuilder = URLBuilder()
    init(session: UserSession) {
        self.session = session
    }
    
    //同期
    func fetch() async throws -> [List] {
        let url = try urlBuilder.makeURL(
            path: "lists",
            queryItems: [URLQueryItem(name: "userId", value: session.userId)]
        )
        let data = try await sendRequest(url: url, method: "GET")
        return try decoder.decode([List].self, from: data)
    }
    
    //追加
    func add(list: AddListRequest) async throws -> List {
        let url = try urlBuilder.makeURL(
            path: "lists",
            queryItems: [URLQueryItem(name: "userId", value: session.userId)]
        )
        let body = try encoder.encode(list)
        let data = try await sendRequest(url: url, method: "POST", body: body)
        return try decoder.decode(List.self, from: data)
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
}
