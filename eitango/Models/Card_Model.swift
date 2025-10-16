import Foundation

struct Card: Identifiable, Codable {//Iden->ユニークに識別可能に,Coda->書き込み読み込み可能
    var id = UUID()
    var en: String
    var jp: String
}
