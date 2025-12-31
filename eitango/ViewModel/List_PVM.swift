//================================================
// 🐿️List_PVM.swift <リスト関連関数>
// ===============================================
// 【役割】
// ・Firestore …… 唯一の正（真実のデータ）
// ・CoreData …… キャッシュ／オフライン用コピー
// ・UI ………… CoreData のみを見る
//
// 【基本フロー】
// １ API で Firestore を操作（追加・更新・削除）
// ２ 操作後は必ず fetchLists を呼ぶ
// ３ fetchLists が Firestore → CoreData を完全同期
// ４ UI は CoreData の変更を自動反映
//
// 【重要ルール】
// ・CoreData を直接いじっても最終的には Firestore が正
// ・fetchCards 内では CoreData を一度全削除して入れ直す
// ・ズレを残さないことを最優先とする設計
//
// 【注意】
// ⚠️ fetchLists の全削除処理は意図的
// ⚠️ 最適化や部分更新を入れる前に必ず設計を再確認すること
//
// ===============================================

import SwiftUI
import CoreData

extension PlayViewModel{
    
    //========
    //🔁同期🔁
    //========
    
    func fetchLists(userId: String) {
        guard let url = URL(string: urlsession + "lists?userId=\(userId)") else {
            print("URLエラー")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("通信エラー: \(error)")
                return
            }
            guard let data = data else {
                print("データなしっピ")
                return
            }

            do {
                print("Raw data: \(String(data: data, encoding: .utf8) ?? "nil")")
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode([List_ST].self, from: data)
                print("Decoded result: \(result)")

                DispatchQueue.main.async {
                    let context = PersistenceController.shared.container.viewContext

                    // CoreData の既存リストを全削除
                    let oldLists = self.fetchListsFromCoreData()
                    oldLists.forEach { context.delete($0) }

                    // Firestore の内容を CoreData に保存
                    for l in result {
                        let entity = ListEntity(context: context)
                        entity.id = l.id
                        entity.title = l.title
                        entity.createdAt = l.createdAt
                    }

                    do {
                        try context.save()
                    } catch {
                        print("保存エラー: \(error)")
                    }
                    self.Lists = self.fetchListsFromCoreData()
                    self.updateView()
                }

            } catch {
                print("デコード失敗: \(error), raw data: \(String(data: data, encoding: .utf8) ?? "nil")")
            }

        }.resume() // 通信を開始
    }
    
    //==============================================
    //📩読み込み📩
    // 🔒表示状態更新専用
    // - CoreData から読み取るだけ
    // - 書き込み・削除・API 呼び出し禁止
    // - ViewModel の @Published を更新するためだけの関数
    //===============================================

    
    func fetchListsFromCoreData() -> [ListEntity] {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ListEntity.createdAt, ascending: false)]
        do{
            let lists = try context.fetch(request)
            return lists
        }catch{
            print("loadcardlisterror: \(error.localizedDescription)")
            return []
        }
    }
    
    //=======
    //📝追加📝
    //========
    
    func addListAPI(
        userId: String,
        title: String,
        completion: @escaping (String?) -> Void
    ) {
        guard let url = URL(string: "\(userId)") else {
            print("URLエラー")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "title": title
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("通信エラー: \(error)")
                completion(nil)
                return
            }

            guard let data else {
                print("レスポンスなし")
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(CreateListResponse.self, from: data)
                DispatchQueue.main.async {
                    // 🔁 Firestore を正として同期
                    self.fetchLists(userId: userId)
                    completion(result.id)
                }
            } catch {
                print("デコード失敗: \(error)")
                completion(nil)
            }

        }.resume()
    }
    
//    func addCardList(title: String) -> ListEntity? {
//        // 新しい単語リストを追加するためのコンテキストを取得します。
//        let context = PersistenceController.shared.container.viewContext
//
//        // CardlistEntity（単語リスト）の新規インスタンスをコンテキスト内に作成。
//        let newList = ListEntity(context: context)
//
//        // リストの各プロパティに値をセットします。
//        newList.id = UUID()          // 一意な識別子
//        newList.title = title        // タイトル名
//        newList.createdAt = Date()   // 作成日時
//
//        do {
//            // 変更内容を永続化します。成功すれば新規リストを返却。
//            try context.save()
//            return newList
//            //新しいカードリストを作らないといけないのでreturn必要あり
//        } catch {
//            // 保存失敗時はエラー内容を表示し、nilを返します。
//            print("addcardlisterror: \(error.localizedDescription)")
//            return nil
//        }
//    }
    
    //==========
    //❌削除関数❌
    //==========
    
    func deleteListAPI(userId: String, listId: String) {
        guard let url = URL(
            string: urlsession + "(userId)&listId=\(listId)"
        ) else {
            print("URLエラー")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("通信エラー: \(error)")
                return
            }

            DispatchQueue.main.async {
                // 🔁 Firestore を正として CoreData を作り直す
                self.fetchLists(userId: userId)
            }
        }.resume()
    }
    
//    func deleteCardList(_ list: ListEntity) {
//        let context = PersistenceController.shared.container.viewContext
//        context.delete(list)
//        do {
//            try context.save()
//        } catch {
//            print("deleteCardListError: \(error.localizedDescription)")
//        }
//    }
    
}
