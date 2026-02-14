import Foundation

protocol DataBaseRepositoryProtocol {
    func fetch_User_DB(userId: String) async throws -> User_ST
    func add_User_DB(name: String, id: String) async throws -> User_ST
    func delete_User_DB(userId: String) async throws
}

final class DataBaseRepository: DataBaseRepositoryProtocol {
    
    //URL定義
    private let urlBuilder: URLBuilder
    init(baseURL: String) {
        self.urlBuilder = URLBuilder(baseURL: baseURL)
    }

    //デコード(Json->Swift)
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    //エンコード(Swift->Json)
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    //リクエスト送信
    private func sendRequest(
        url: URL,
        method: String,
        body: Data? = nil
    ) async throws -> Data {
        do {
            var request = URLRequest(url: url)
            request.httpMethod = method
            if let body = body {
                request.httpBody = body
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                throw DBError.invalidResponse
            }
            return data
        } catch {
            throw DBError.network
        }
    }
    
    //同期
    func fetch_User_DB(userId: String) async throws -> User_ST {
        let url = try urlBuilder.makeURL(
            path: "users",
            queryItems: [URLQueryItem(name: "userId", value: userId)]
        )
        let data = try await sendRequest(url: url, method: "GET")
        return try decoder.decode(User_ST.self, from: data)
    }
    
    //追加
    func add_User_DB(name: String, id: String) async throws -> User_ST {
        let url = try urlBuilder.makeURL(path: "users")
        let body = try encoder.encode(AddUserRequest(id: id, name: name))
        let data = try await sendRequest(url: url, method: "POST", body: body)
        return try decoder.decode(User_ST.self, from: data)
    }
    
    //削除
    func delete_User_DB(userId: String) async throws {
        let url = try urlBuilder.makeURL(
            path: "users",
            queryItems: [URLQueryItem(name: "userId", value: userId)]
        )
        _ = try await sendRequest(url: url, method: "DELETE")
    }
}
