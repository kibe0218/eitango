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
    
    //===========
    //👀同期関数👀
    //===========
    
//    func fetchCards(userId: String, listId: String) {
//        guard let url = URL(string:
//            "http://localhost:8080/cards?userId=\(userId)&listId=\(listId)"
//        ) else {
//            print("URLエラー")
//            return
//        }
//        //Getを読んでいる
//        URLSession.shared.dataTask(with: url) { data, response, error in
//
//            if let error = error {
//                print("通信エラー: \(error)")
//                return
//            }
//            guard let data = data else {
//                print("データなしっピ")
//                return
//            }
//            do {
//                let decoder = JSONDecoder()
//                decoder.dateDecodingStrategy = .iso8601
//                let result = try decoder.decode([Card_ST].self, from: data)
//                //JSONをCard型に変換
//                DispatchQueue.main.async {
//                    let context = PersistenceController.shared.container.viewContext
//
//                    //全てのcoredataに入ってるリストを取得その中からidが同じものを探すなかったらnilになるのでifがfalseになり中断
//                    if let targetList = self.loadCardList()
//                        .first(where: { $0.id == listId }) {
//                        let oldCards = self.loadCards(from: targetList)
//                        //oldCardsの中身を全て消すoldcardsはcoredataの実物への参照だからcoredataにも影響を与える
//                        oldCards.forEach { context.delete($0) }
//                        // ② Firestore のカードを CoreData に保存
//                        for c in result {
//                            let entity = CardEntity(context: context)
//                            entity.id = c.id
//                            entity.en = c.en
//                            entity.jp = c.jp
//                            entity.createdAt = c.createdAt
//                            entity.cardlist = targetList
//                            entity.listId = listId
//                        }
//
//                        do {
//                            try context.save()
//                        } catch {
//                            print("保存エラー: \(error)")
//                        }
//
//                        // ③ loadCards で表示データ更新
//                        self.cards = self.loadCards(from: targetList)
//                    }
//                }
//
//            } catch {
//                print("デコード失敗: \(error)")
//            }
//
//        }.resume()//通信を開始する命令
//    }
    
    //======================
    //📩Coredataから読み込む📩
    //======================
    
    func loadCards(title: String) -> [CardEntity] {
        if let list = loadCardList().first(where: { $0.title == title }) {
            return loadCards(from: list)
        } else {
            return []
        }
    }
    
    func loadCards(from list: CardlistEntity) -> [CardEntity] {
        // データの読み書きを司るコンテキストを取得します。
        let context = PersistenceController.shared.container.viewContext
        
        // CardEntity（単語カード）を取得するためのリクエストを作成します。
        let request: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        // 🔁 Firestore の listId を正としてカードを取得する
        // cardlist（CoreDataのリレーション）ではなく listId（String）で絞り込む
        request.predicate = NSPredicate(format: "cardlist == %@", list)
        //request.predicate = NSPredicate(format: "listId == %@", list.id ?? "")
        
        // 取得結果を作成日時の昇順でソートする指定を加えています。
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardEntity.createdAt, ascending: false)]
        //keyPath:どのプロパティで並び替えるか,ascending:昇順（true)or降順
        
        do{
            // コンテキストを通じてデータベースからカードを取得します。
            let cards = try context.fetch(request)
            return cards
        }catch{
            // エラーが起きた場合は詳細を表示し、空の配列を返します。
            print("loadcardserror: \(error.localizedDescription)")
            return []
        }
    }
    
    //=======
    //📝追加📝
    //========
    
//    func addCardAPI(
//        userId: String,
//        listId: String,
//        en: String,
//        jp: String
//    ) {
//        guard let url = URL(
//            string: "http://localhost:8080/cards?userId=\(userId)&listId=\(listId)"
//        ) else {
//            print("URLエラーっピ")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let body: [String: Any] = [
//            "en": en,
//            "jp": jp
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        } catch {
//            print("JSON変換エラーっピ: \(error)")
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("通信エラーっピ: \(error)")
//                return
//            }
//
//            DispatchQueue.main.async {
//                // 🔁 Firestore を正として CoreData を同期
//                self.fetchCards(userId: userId, listId: listId)
//            }
//        }.resume()
//    }
    
    func addCard(to list: CardlistEntity, en: String, jp: String) {
        let context = PersistenceController.shared.container.viewContext
        let newCard = CardEntity(context: context)

        newCard.id = UUID()
        newCard.en = en
        newCard.jp = jp
        newCard.createdAt = Date()
        newCard.cardlist = list
        list.addToCards(newCard)

        do {
            try context.save()
        } catch {
            print("addcarderror: \(error.localizedDescription)")
        }
    }
    
    //========
    //🔁更新🔁
    //========
    
//    func updateCardAPI(
//        userId: String,
//        listId: String,
//        cardId: String,
//        en: String,
//        jp: String,
//        createdAt: Date
//    ) {
//        guard let url = URL(
//            string: "http://localhost:8080/cards?userId=\(userId)&listId=\(listId)&cardId=\(cardId)"
//        ) else {
//            print("URLエラーっピ")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        //Content-Typeでapplication/jsonを指定している
//        let body: [String: Any] = [
//            "en": en,
//            "jp": jp,
//            "createdAt": ISO8601DateFormatter().string(from: createdAt)
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        } catch {
//            print("JSON変換エラーっピ: \(error)")
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("通信エラーっピ: \(error)")
//                return
//            }
//
//            DispatchQueue.main.async {
//                // 🔁 更新後は一覧を再取得
//                self.fetchCards(userId: userId, listId: listId)
//            }
//        }.resume()
//    }
    
    //==========
    //❌削除関数❌
    //==========
    
//    func deleteCardAPI(
//        userId: String,
//        listId: String,
//        cardId: String
//    ) {
//        guard let url = URL(
//            string: "http://localhost:8080/cards?userId=\(userId)&listId=\(listId)&cardId=\(cardId)"
//        ) else {
//            print("URLエラーっピ")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//
//        URLSession.shared.dataTask(with: request) { _, _, error in
//            if let error = error {
//                print("通信エラーっピ: \(error)")
//                return
//            }
//
//            DispatchQueue.main.async {
//                // 🔁 削除後は Firestore を正として再取得
//                self.fetchCards(userId: userId, listId: listId)
//            }
//        }.resume()
//    }
    
    func deleteCard(_ card: CardEntity) {
        let context = PersistenceController.shared.container.viewContext
        context.delete(card)
        do {
            try context.save()
        } catch {
            print("deleteCardError: \(error.localizedDescription)")
        }
    }
    
}
