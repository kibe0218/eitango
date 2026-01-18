import SwiftUI
import CoreData

extension PlayViewModel {
    //==========
    //最初の処理🈁
    //==========
    
    func reinit() {
        Task {
            ColorSetting()
            loadSettings()
            self.User = self.fetchUserFromCoreData()
            self.userid = self.User?.id ?? ""
            self.userName = self.User?.name ?? ""
            await self.fetchLists(userId: userid)
            await initialSyncAllCards()
        }
    }
    
    //=====================
    //coredataだけ消す💨
    //=====================
    
    func backToDefaultCoreData() {
        let context = PersistenceController.shared.container.viewContext
        do {
            // 👤 User 削除
            if let oldUser = self.fetchUserFromCoreData() {
                context.delete(oldUser)
            }
            // 📋 List 削除
            let oldLists = self.fetchListsFromCoreData()
            oldLists.forEach { context.delete($0) }
            
            // 🃏 Card 全削除
            let allCardsRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
            let allCards = try context.fetch(allCardsRequest)
            allCards.forEach { context.delete($0) }
            
            
            // ⚙️ 設定をデフォルトに
            self.defaultSettings()
            
            // 💾 一括保存
            try context.save()
            saveSettings()
            
            // 🔍 確認ログ
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            let allUsers = try context.fetch(request)
            print("🟡 backToDefaultCoreData 完了 / User残数 =", allUsers.count)
        } catch {
            context.rollback()
            print("🟡 [backToDefaultCoreData] CoreData error:", error.localizedDescription)
        }
    }
    
    //============
    //全てを同期♻️♻️
    //============
    
    func fetchAllToCoreData() {
        Task {
            await self.fetchLists(userId: self.User?.id ?? "")
            
        }
    }
    
}
