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
    
//    func fetchLists(userId: String) {
//        guard let url = URL(string: "http://localhost:8080/lists?userId=\(userId)") else {
//            print("URLエラー")
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("通信エラー: \(error)")
//                return
//            }
//            guard let data = data else {
//                print("データなしっピ")
//                return
//            }
//
//            do {
//                let decoder = JSONDecoder()
//                decoder.dateDecodingStrategy = .iso8601
//                let result = try decoder.decode([List_ST].self, from: data)
//
//                DispatchQueue.main.async {
//                    let context = PersistenceController.shared.container.viewContext
//
//                    // CoreData の既存リストを全削除
//                    let oldLists = self.loadCardList()
//                    oldLists.forEach { context.delete($0) }
//
//                    // Firestore の内容を CoreData に保存
//                    for l in result {
//                        let entity = CardlistEntity(context: context)
//                        entity.id = l.id
//                        entity.title = l.listname
//                        entity.createdAt = l.createdAt
//                    }
//
//                    do {
//                        try context.save()
//                    } catch {
//                        print("保存エラー: \(error)")
//                    }
//                }
//
//            } catch {
//                print("デコード失敗: \(error)")
//            }
//
//        }.resume() // 通信を開始
//    }
//    
    //===========
    //📩読み込み📩
    //===========
    
    func loadCardList() -> [CardlistEntity] {
        let context = PersistenceController.shared.container.viewContext
        
        // 取得したいエンティティ（データの種類）を指定するリクエストを作成します。
        // ここではCardlistEntity（単語リスト）を取得するためのリクエストを生成。
        let request: NSFetchRequest<CardlistEntity> = CardlistEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardlistEntity.createdAt, ascending: false)]
        //let request: NSFetchRequest<Entity名> = Entity名.fetchReequest()
        
        do{
            // 実際にコンテキストを通じてデータベースからデータを取得します。
            // 取得に成功すれば配列で返却し、失敗した場合はcatch節へと進みます。
            let lists = try context.fetch(request)
            //context.fetch(request)で実際にリクエストを実行
            return lists
        }catch{
            // エラーが発生した場合、その詳細をコンソールに出力し、空の配列を返します。
            print("loadcardlisterror: \(error.localizedDescription)")
            return []
        }
    }
    
    //=======
    //📝追加📝
    //========
    
//    func addListAPI(userId: String, title: String) {
//        guard let url = URL(string: "http://localhost:8080/lists?userId=\(userId)") else {
//            print("URLエラー")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // Go 側の List struct に合わせる
//        let body: [String: Any] = [
//            "listname": title
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        } catch {
//            print("JSON作成エラー: \(error)")
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { _, response, error in
//            if let error = error {
//                print("通信エラー: \(error)")
//                return
//            }
//
//            DispatchQueue.main.async {
//                // 🔁 Firestore を正として CoreData を作り直す
//                self.fetchLists(userId: userId)
//            }
//        }.resume()
//    }
    
    func addCardList(title: String) -> CardlistEntity? {
        // 新しい単語リストを追加するためのコンテキストを取得します。
        let context = PersistenceController.shared.container.viewContext
        
        // CardlistEntity（単語リスト）の新規インスタンスをコンテキスト内に作成。
        let newList = CardlistEntity(context: context)
        
        // リストの各プロパティに値をセットします。
        newList.id = UUID()          // 一意な識別子
        newList.title = title        // タイトル名
        newList.createdAt = Date()   // 作成日時
        
        do {
            // 変更内容を永続化します。成功すれば新規リストを返却。
            try context.save()
            return newList
            //新しいカードリストを作らないといけないのでreturn必要あり
        } catch {
            // 保存失敗時はエラー内容を表示し、nilを返します。
            print("addcardlisterror: \(error.localizedDescription)")
            return nil
        }
    }
    
    //==========
    //❌削除関数❌
    //==========
    
//    func deleteListAPI(userId: String, listId: String) {
//        guard let url = URL(
//            string: "http://localhost:8080/lists?userId=\(userId)&listId=\(listId)"
//        ) else {
//            print("URLエラー")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//
//        URLSession.shared.dataTask(with: request) { _, response, error in
//            if let error = error {
//                print("通信エラー: \(error)")
//                return
//            }
//
//            DispatchQueue.main.async {
//                // 🔁 Firestore を正として CoreData を作り直す
//                self.fetchLists(userId: userId)
//            }
//        }.resume()
//    }
    
    func deleteCardList(_ list: CardlistEntity) {
        let context = PersistenceController.shared.container.viewContext
        context.delete(list)
        do {
            try context.save()
        } catch {
            print("deleteCardListError: \(error.localizedDescription)")
        }
    }
    
}
