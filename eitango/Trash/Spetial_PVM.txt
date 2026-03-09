import SwiftUI
import CoreData

extension PlayViewModel {
    
    // ==========
    // 最初の処理🈁
    // ==========
    
    func reinit() {
        Task {
            ColorSetting()
            loadSettings()
            self.User = self.fetchUserFromCoreData()
            self.userid = self.User?.id ?? ""
            self.userName = self.User?.name ?? ""
            await self.fetchLists(userId: userid)
            await fetchAllToCoreData()
        }
    }
    
    // =====================
    // coredataだけ消す💨
    // =====================
    
    func backToDefaultCoreData() {
        let context = PersistenceController.shared.container.viewContext
        do {
            //  👤 User 削除
            if let oldUser = self.fetchUserFromCoreData() {
                context.delete(oldUser)
            }
            //  📋 List 削除
            let oldLists = self.fetchListsFromCoreData()
            oldLists.forEach { context.delete($0) }
            
            //  🃏 Card 全削除
            let allCardsRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
            let allCards = try context.fetch(allCardsRequest)
            allCards.forEach { context.delete($0) }
            
            
            //  ⚙️ 設定をデフォルトに
            self.defaultSettings()
            
            //  💾 一括保存
            try context.save()
            saveSettings()
            
            //  🔍 確認ログ
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            let allUsers = try context.fetch(request)
            print("🟡 backToDefaultCoreData 完了 / User残数 =", allUsers.count)
        } catch {
            context.rollback()
            print("🟡 [backToDefaultCoreData] CoreData error:", error.localizedDescription)
        }
    }
    
    // ============
    // 全てを同期♻️♻️
    // ============
    
    func fetchAllToCoreData() async {
        await self.fetchLists(userId: self.User?.id ?? "")
        print("🟡 初回同期開始: list数 = \(self.Lists.count)")

        for list in self.Lists {
            guard let listId = list.id else { continue }
            print("🟡 初回同期 fetchCards 実行: listId = \(listId)")
            await self.fetchCards(listId: listId)
        }
    }
}
