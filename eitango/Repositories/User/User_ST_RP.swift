import Foundation

struct User_ST: Codable, Identifiable {
    let id: String
    let name: String
    let createdAt: Date?
}

struct AddUserRequest: Encodable {
    let id: String
    let name: String
}

nonisolated
struct AddUserResponse: Decodable {
    let message: String
    let id: String
}
