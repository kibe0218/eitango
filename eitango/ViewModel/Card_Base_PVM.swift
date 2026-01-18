//================================================
// 🃏【Card_PVM / カード管理ロジック】
//================================================
//
// 【役割】
// ・🔥 Firestore …… 唯一の正（真実のデータ）
// ・💾 CoreData …… キャッシュ／オフライン用コピー
// ・🖥 UI ………… CoreData のみを監視して描画
//
// 【基本フロー】
// ① API で Firestore を操作（追加・更新・削除）
// ② 操作後は必ず fetchCards を呼ぶ
// ③ fetchCards が Firestore → CoreData を完全同期
// ④ UI は CoreData の変更を自動反映
//
// 【重要ルール】
// ・⚠️ CoreData を直接操作しても最終的な正は Firestore
// ・⚠️ fetchCards 内では CoreData を一度全削除して入れ直す
// ・⚠️ 差分更新は行わず「ズレを残さない」ことを最優先
//
// 【設計意図】
// ・CoreData は View のための読み取り専用キャッシュ
// ・状態不整合を防ぐため「同期は一方向のみ」
// ・fetchCards は「掃除＋再配置」を行う同期職人
//
// 【注意】
// ❗ fetchCards の全削除は仕様
// ❗ 最適化（差分更新）を入れる場合は設計を再検討すること
//
//================================================

import SwiftUI
import CoreData

extension PlayViewModel{
    
    //==========================
    //🌱 初回同期（全カード取得）🌱
    //==========================
    func initialSyncAllCards() async {
        print("🟡 初回同期開始: list数 = \(self.Lists.count)")

        for list in self.Lists {
            guard let listId = list.id else { continue }
            print("🟡 初回同期 fetchCards 実行: listId = \(listId)")
            await self.fetchCards(listId: listId)
        }
    }
    
    //========
    //🔁同期🔁
    //========
    func fetchCards(listId: String) async {
        guard let url = URL(string: urlsession + "cards?userId=\(self.userid)&listId=\(listId)"
        ) else {
            print("URLエラー")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode([Card_ST].self, from: data)
            //JSONをCard型に変換
            let context = PersistenceController.shared.container.viewContext
            if let targetList = self.fetchListsFromCoreData()
                .first(where: { $0.id == listId }) {
                guard let listid = targetList.id else {
                    print("listIdがnilっピ")
                    return
                }
                let oldCards = self.fetchCardsFromCoreData(listid: listid)
                oldCards.forEach { context.delete($0) }
                // ② Firestore のカードを CoreData に保存
                for c in result {
                    let entity = CardEntity(context: context)
                    entity.id = c.id
                    entity.listid = listid
                    entity.en = c.en
                    entity.jp = c.jp
                    entity.createdAt = c.createdAt
                }

                do {
                    try context.save()
                } catch {
                    print("保存エラー: \(error)")
                }

                await MainActor.run {
                    self.Cards = self.fetchCardsFromCoreData(listid: listid)
                }
            }
        } catch {
            print("通信またはデコード失敗: \(error)")
        }
    }
    
    //======================
    //📩Coredataから読み込む📩
    //======================
    
    func fetchCardsFromCoreData(listid: String) -> [CardEntity] {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        request.predicate = NSPredicate(format: "listid == %@", listid as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardEntity.createdAt, ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("fetchCardsFromCoreData(listId:) error: \(error.localizedDescription)")
            return []
        }
    }
    
    //=======
    //📝追加📝
    //========
    
    func addCardAPI(
        listId: String,
        en: String,
        jp: String
    ) async {
        guard let url = URL(
            string: urlsession + "cards?userId=\(self.userid)&listId=\(listId)"
        ) else {
            print("🟡 URLエラーっピ")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "en": en,
            "jp": jp
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("🟡 JSON変換エラーっピ: \(error)")
            return
        }

        do {
            _ = try await URLSession.shared.data(for: request)
            // 🔁 Firestore を正として CoreData を同期
            await fetchCards(listId: listId)
        } catch {
            print("🟡 通信エラーっピ: \(error)")
        }
    }
    
    //=====
    //翻訳
    //=====
    
    func translateTextWithGAS(_ text: String, source: String = "en", target: String = "ja") async throws -> String {
        // addingPercentEncodingで＋＋などの特殊文字を安全な文字列に変換
        // withAllowedCharacters: .urlQueryAllowedは空白や？を%26などに変換
        // withAllowedChaaractersはURLに安全にう目込むためのルールを指定するところ
        let urlString = "https://script.google.com/macros/s/AKfycbxotVWEIFCz2YhhUZSdPJ7jkYlQKj2W2ya7QWRlFiGixeRaoFg7P9E75HfgQEN-GakP/exec?text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&source=\(source)&target=\(target)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // レスポンスデータをJSONとしてデコードし、ステータスコードと翻訳結果を抽出する、辞書型
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let code = json["code"] as? Int,
            code == 200,
            let translated = json["text"] as? String { // 翻訳テキストを取得
            return translated.removingPercentEncoding ?? translated
        } else {
            throw NSError(domain: "TranslationAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "翻訳失敗"])
        }
    }
    
    //========
    //🔁更新🔁
    //========
    
    func updateCardAPI(
        listId: String,
        cardId: String,
        en: String,
        jp: String,
        createdAt: Date
    ) async {
        guard let url = URL(
            string: urlsession + "cards?userId=\(self.userid)&listId=\(listId)&cardId=\(cardId)"
        ) else {
            print("URLエラーっピ")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //Content-Typeでapplication/jsonを指定している
        let body: [String: Any] = [
            "id": cardId,
            "listid": listId,
            "en": en,
            "jp": jp,
            "createdAt": ISO8601DateFormatter().string(from: createdAt)
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("JSON変換エラーっピ: \(error)")
            return
        }

        do {
            _ = try await URLSession.shared.data(for: request)
            // 🔁 更新後は一覧を再取得
            await fetchCards(listId: listId)
        } catch {
            print("通信エラーっピ: \(error)")
        }
    }
    
    //==========
    //❌削除関数❌
    //==========
    
    func deleteCardAPI(
        userId: String,
        listId: String,
        cardId: String
    ) async {
        guard let url = URL(
            string: urlsession + "cards?userId=\(userId)&listId=\(listId)&cardId=\(cardId)"
        ) else {
            print("URLエラーっピ")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            _ = try await URLSession.shared.data(for: request)
            // 🔁 削除後は Firestore を正として再取得
            await fetchCards(listId: listId)
        } catch {
            print("通信エラーっピ: \(error)")
        }
    }
}
