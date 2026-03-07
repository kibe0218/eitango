import Foundation

struct Card_ST: Codable, Identifiable, Equatable {
    var id: String
    var listId: String
    var en: String
    var jp: String
    var createdAt: Date?
    var order: Int
}

struct AddCardRequest: Encodable {
    let en: String
    let jp: String
}

struct UpdateCardRequest: Encodable {
    let id: String
    let en: String
    let jp: String
}
