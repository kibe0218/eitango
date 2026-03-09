import Foundation

struct List: Codable, Identifiable {
    let id: String
    let title: String
    let createdAt: Date?
    var cardCount: Int
}
