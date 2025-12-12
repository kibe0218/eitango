import Foundation

struct Card: Codable, Identifiable {
    var id: String
    var en: String
    var jp: String
    var createdAt: Date?
}
