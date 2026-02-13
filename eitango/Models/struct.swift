import Foundation

struct Card_ST: Codable, Identifiable {
    var id: String
    var listid: String
    var en: String
    var jp: String
    var createdAt: Date?
}

struct List_ST: Codable, Identifiable {
    let id: String       // Firestore の documentID
    let title: String
    let createdAt: Date?
}

nonisolated 
struct CreateListResponse: Decodable {
    let id: String
}

nonisolated
struct AddUserResponse: Decodable {
    let message: String
    let id: String
}

struct AddUserRequest: Encodable {
    let id: String
    let name: String
}

struct User_ST: Codable, Identifiable {
    let id: String
    let name: String
    let createdAt: Date?
}
