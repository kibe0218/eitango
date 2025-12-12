import SwiftUI
import CoreData

extension PlayViewModel{
    
    func loadSettings() {
        // Core Dataのコンテキストを取得
        let context = PersistenceController.shared.container.viewContext
        // AppSettingsエンティティのフェッチリクエストを作成
        let request: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
        do {
            // AppSettingsは1件のみ保存される想定
            if let settings = try context.fetch(request).first {
                self.number = Int(settings.number)
                self.shuffleFlag = settings.shuffleFlag
                self.repeatFlag = settings.repeatFlag
                self.colortheme = Int(settings.colortheme)
                self.waittime = Int(settings.waittime)
            } else {
                // データが存在しない場合はデフォルト値を設定
                self.number = 0
                self.shuffleFlag = false
                self.repeatFlag = false
                self.colortheme = 1
                self.waittime = 2
            }
        } catch {
            // エラー発生時はデフォルト値を設定
            print("loadSettingsError: \(error.localizedDescription)")
            self.number = 0
            self.shuffleFlag = false
            self.repeatFlag = false
            self.colortheme = 1
            self.waittime = 2
        }
    }
    
    func saveSettings() {
        // Core Dataのコンテキストを取得
        let context = PersistenceController.shared.container.viewContext
        // AppSettingsエンティティのフェッチリクエストを作成
        let request: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
        do {
            // 既存のAppSettingsを取得、なければ新規作成
            let settings: AppSettings
            if let existing = try context.fetch(request).first {
                settings = existing
            } else {
                settings = AppSettings(context: context)
                settings.id = UUID()
            }
            // 値を更新
            settings.number = Int16(number)
            settings.shuffleFlag = shuffleFlag
            settings.repeatFlag = repeatFlag
            settings.colortheme = Int16(colortheme)
            settings.waittime = Int16(waittime)
            try context.save()
        } catch {
            print("saveSettingsError: \(error.localizedDescription)")
        }
    }
}
