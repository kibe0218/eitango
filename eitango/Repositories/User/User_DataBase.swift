import Foundation

protocol User_DataBaseRepositoryProtocol {
    func fetch() async throws -> User
    func add(user: AddUserRequest) async throws -> User
    func delete() async throws
}

final class User_DataBaseRepository: User_DataBaseRepositoryProtocol {
    
    //URL定義
    private let session: UserSession
    let urlBuilder = URLBuilder()
    init(session: UserSession) {
        self.session = session
    }
    
    //同期
    func fetch() async throws -> User {
        let url = try urlBuilder.makeURL(
            path: "users",
            queryItems: [URLQueryItem(name: "userId", value: session.userId)]
        )
        let data = try await sendRequest(url: url, method: "GET")
        return try decoder.decode(User.self, from: data)
    }
    
    //追加
    func add(user: AddUserRequest) async throws -> User {
        let url = try urlBuilder.makeURL(path: "users")
        let body = try encoder.encode(user)
        let data = try await sendRequest(url: url, method: "POST", body: body)
        return try decoder.decode(User.self, from: data)
    }
    
    //削除
    func delete() async throws {
        let url = try urlBuilder.makeURL(
            path: "users",
            queryItems: [URLQueryItem(name: "userId", value: session.userId)]
        )
        _ = try await sendRequest(url: url, method: "DELETE")
    }
}
