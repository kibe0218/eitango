//================================================
// 📦 struct.swift / APIレスポンス用データ定義
//================================================
//
// 【役割】
// ・Go API / Firestore から受け取るデータ構造を定義
// ・SwiftUI / ViewModel / CoreData で共通利用する型
// ・Firestore の documentID を id として保持
//
// 【対象構造体】
// ・Card …… 単語カード（英語・日本語）
// ・List …… 単語リスト（カードの親）
//
// 【設計方針】
// ・Codable に準拠し API レスポンスをそのまま decode
// ・Identifiable に準拠し SwiftUI の List / ForEach で使用
// ・id は Firestore 側で生成された documentID を利用
//
// 【重要ルール】
// ・⚠️ id は UUID ではなく String（Firestore 由来）
// ・⚠️ createdAt は Firestore Timestamp → Date 変換後の値
// ・⚠️ この struct は「APIとの契約」なので安易に変更しない
//
// 【補足】
// ・CoreData 用 Entity とは別物（変換は ViewModel で行う）
// ・UI は直接 Firestore を知らず、この struct を通して扱う
//
//================================================
import Foundation

struct Card_ST: Codable, Identifiable {
    var id: String
    var en: String
    var jp: String
    var createdAt: Date?
}

struct List_ST: Codable, Identifiable {
    let id: String          // Firestore の documentID
    let listname: String
    let createdAt: Date?
}
