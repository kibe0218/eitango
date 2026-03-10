import Foundation

protocol User_DataBaseRepositoryProtocol {
    func fetch(id: String) async throws -> User
    func add(user: AddUserRequest) async throws -> User
    func delete(id: String) async throws
}

final class User_DataBaseRepository: User_DataBaseRepositoryProtocol {
    
    // MARK: - Private Helpers
    
    // URL定義
    let urlBuilder = URLBuilder()
    
    // MARK: - Public CRUD Functions
    
    // 同期
    func fetch(id: String) async throws -> User {
        let url = try urlBuilder.makeURL(
            path: "users",
            queryItems: [URLQueryItem(name: "userId", value: id)]
        )
        let data = try await sendRequest(url: url, method: "GET")
        return try decoder.decode(User.self, from: data)
    }
    
    // 追加
    func add(user: AddUserRequest) async throws -> User {
        let url = try urlBuilder.makeURL(path: "users")
        let body = try encoder.encode(user)
        let data = try await sendRequest(url: url, method: "POST", body: body)
        return try decoder.decode(User.self, from: data)
    }
    
    // 削除
    func delete(id: String) async throws {
        let url = try urlBuilder.makeURL(
            path: "users",
            queryItems: [URLQueryItem(name: "userId", value: id)]
        )
        _ = try await sendRequest(url: url, method: "DELETE")
    }
}
