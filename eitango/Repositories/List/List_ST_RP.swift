import Foundation

struct List_ST: Codable, Identifiable {
    let id: String
    let title: String
    let createdAt: Date?
    let cardCount: Int
}

struct AddListRequest: Encodable {
    let title: String
}
