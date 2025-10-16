import Foundation

struct WordBook: Identifiable, Codable {
    var id = UUID()           // 単語帳自体のユニークID
    var title: String         // 単語帳名
    var cards: [Card] = []    // 単語カードの配列
}
