import Foundation

protocol List_DataBaseRepositoryProtocol {
    func fetchAll(userId: String) async throws -> [List]
    func add(userId: String, list: AddListRequest) async throws -> List
    func delete(userId: String, id: String) async throws
}

final class List_DataBaseRepository: List_DataBaseRepositoryProtocol {
    
    // MARK: - Private Helpers
    
    // URL定義
    let urlBuilder = URLBuilder()
    
    // MARK: - Public CRUD Functions
    
    // 同期
    func fetchAll(userId: String) async throws -> [List] {
        let url = try urlBuilder.makeURL(
            path: "lists",
            queryItems: [URLQueryItem(name: "userId", value: userId)]
        )
        let data = try await sendRequest(url: url, method: "GET")
        return try decoder.decode([List].self, from: data)
    }
    
    // 追加
    func add(userId: String, list: AddListRequest) async throws -> List {
        let url = try urlBuilder.makeURL(
            path: "lists",
            queryItems: [URLQueryItem(name: "userId", value: userId)]
        )
        let body = try encoder.encode(list)
        let data = try await sendRequest(url: url, method: "POST", body: body)
        return try decoder.decode(List.self, from: data)
    }
    
    // 削除
    func delete(userId: String, id: String) async throws {
        let url = try urlBuilder.makeURL(
            path: "users",
            queryItems: [
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "listId", value: id)
            ]
        )
        _ = try await sendRequest(url: url, method: "DELETE")
    }
}
