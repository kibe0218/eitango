import Foundation

struct CardList: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let createdAt: Date?
    var cardCount: Int
}
