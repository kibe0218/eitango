import Foundation

protocol User_DataBaseRepositoryProtocol {
    func fetch(id: String) async throws -> User
    func add(id: String) async throws
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
    func add(id: String) async throws {
        let url = try urlBuilder.makeURL(path: "users")
        let request = AddUserRequest(id: id)
        let body = try encoder.encode(request)
        let data = try await sendRequest(url: url, method: "POST", body: body)
        print("fuck")
        print("🟡 url: \(url)")
        print("🟡 body: \(String(decoding: body, as: UTF8.self))")
        print("🟡 data = \(String(decoding: data, as: UTF8.self))")
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
