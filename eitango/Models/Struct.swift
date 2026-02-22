import Foundation
import SwiftUI

//カード
struct Card_ST: Codable, Identifiable {
    var id: String
    var listid: String
    var en: String
    var jp: String
    var createdAt: Date?
}

struct AddCardRequest: Encodable {
    let en: String
    let jp: String
}

struct UpdateCardRequest: Encodable {
    let en: String
    let jp: String
}

//リスト
struct List_ST: Codable, Identifiable {
    let id: String
    let title: String
    let createdAt: Date?
}

struct AddListRequest: Encodable {
    let title: String
}

nonisolated
struct AddListResponse: Decodable {
    let id: String
}

//ユーザー
struct User_ST: Codable, Identifiable {
    let id: String
    let name: String
    let createdAt: Date?
}

struct AddUserRequest: Encodable {
    let id: String
    let name: String
}

nonisolated
struct AddUserResponse: Decodable {
    let message: String
    let id: String
}

//設定
struct Setting_ST: Codable {
    let colortheme: ColorTheme
    let repeatFlag: Bool
    let shuffleFlag: Bool
    let selectedListId: String?
    let waitTime: Int
}

//色
struct Color_ST {
    let cardColor: Color
    let backColor: Color
    let customaccentColor: Color
    let noaccentColor: Color
    let cardfrontColor: Color
    let cardbackColor: Color
    let toggleColor: Color
    let cardlistColor: Color
    let cardlistmobColor: Color
    let textColor: Color
}
