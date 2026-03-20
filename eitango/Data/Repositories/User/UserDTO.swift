import Foundation

struct AddUserRequest: Encodable {
    let id: String
    let name: String
}

nonisolated
struct AddUserResponse: Decodable {
    let message: String
    let id: String
}
