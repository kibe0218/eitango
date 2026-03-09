import Foundation

struct Card: Codable, Identifiable, Equatable {
    let id: String
    let listId: String
    var en: String
    var jp: String
    let createdAt: Date?
    var order: Int
}
