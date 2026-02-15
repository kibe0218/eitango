import Foundation

//カード
struct Card_ST: Codable, Identifiable {
    var id: String
    var listid: String
    var en: String
    var jp: String
    var createdAt: Date?
}

//リスト
struct List_ST: Codable, Identifiable {
    let id: String
    let title: String
    let createdAt: Date?
}

nonisolated
struct CreateListResponse: Decodable {
    let id: String
}

//ユーザー
struct User_ST: Codable, Identifiable {
    let id: String
    let name: String
    let createdAt: Date?
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

//設定
struct Setting_ST: Codable {
    let colortheme: Int
    let repeatFlag: Bool
    let shuffleFlag: Bool
    let selectedListId: String?
    let waitTime: Int
}
