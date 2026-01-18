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
    
    func fetchLists(userId: String) async {
        guard let url = URL(string: urlsession + "lists?userId=\(userId)") else {
            print("URLエラー")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            print("🟡 raw response:", String(data: data, encoding: .utf8) ?? "nil")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode([List_ST].self, from: data)
            print("Decoded result: \(result)")

            // CoreData 全削除して保存
            let context = PersistenceController.shared.container.viewContext
            let oldLists = fetchListsFromCoreData()
            oldLists.forEach { context.delete($0) }

            for l in result {
                let entity = ListEntity(context: context)
                entity.id = l.id
                entity.title = l.title
                entity.createdAt = l.createdAt
            }

            try context.save()

            await MainActor.run {
                Lists = fetchListsFromCoreData()
                updateView()
            }

        } catch {
            print("fetchLists エラー: \(error)")
        }
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
    
    func addListAPI(userId: String, title: String) async -> String? {
        guard let url = URL(string: urlsession + "lists?userId=\(userId)") else {
            print("URLエラー")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["title": title])

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let id = jsonObject["id"] as? String {
                // Firestore を正として同期
                await fetchLists(userId: userId)
                return id
            } else {
                print("addListAPI: id not found in response")
                return nil
            }

        } catch {
            print("addListAPI エラー: \(error)")
            return nil
        }
    }
    
    //==========
    //❌削除関数❌
    //==========
    
    func deleteListAPI(userId: String, listId: String) async {
        guard let url = URL(string: urlsession + "lists?userId=\(userId)&listId=\(listId)") else {
            print("URL生成失敗")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode = \(httpResponse.statusCode)")
            }

            // 削除後に fetch
            await fetchLists(userId: userId)

        } catch {
            print("deleteListAPI エラー: \(error)")
        }
    }
}
