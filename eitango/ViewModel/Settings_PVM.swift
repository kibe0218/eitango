//================================================
// ⚙️【Settings_PVM / アプリ設定管理】
//================================================
//
// 【役割】
// ・📦 CoreData に保存された設定値の読み書きを担当
// ・🔁 アプリ起動時・画面復帰時の設定復元
// ・🧩 UI と設定データの橋渡し役
//
// 【管理対象】
// ・number（出題数）
// ・shuffleFlag（シャッフル有無）
// ・repeatFlag（繰り返し）
// ・colortheme（配色テーマ）
// ・waittime（待機時間）
//
// 【基本フロー】
// ① loadSettings() で CoreData → ViewModel へ反映
// ② UI 操作で ViewModel の値が更新
// ③ saveSettings() で ViewModel → CoreData に保存
//
// 【設計方針】
// ・設定は Firestore とは同期しない
// ・端末ローカル専用データとして扱う
// ・常に「最後に保存された1件のみ」を正とする
//
// 【注意】
// ⚠️ AppSettings は常に1レコード想定
// ⚠️ 複数保存されない前提のため fetch().first を使用
//
//================================================

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
                self.selectedListId = settings.selectedListId
                self.shuffleFlag = settings.shuffleFlag
                self.repeatFlag = settings.repeatFlag
                self.colortheme = Int(settings.colortheme)
                self.waittime = Int(settings.waittime)
            } else {
                // データが存在しない場合はデフォルト値を設定
                self.selectedListId = nil
                self.shuffleFlag = false
                self.repeatFlag = false
                self.colortheme = 1
                self.waittime = 2
            }
        } catch {
            // エラー発生時はデフォルト値を設定
            print("loadSettingsError: \(error.localizedDescription)")
            self.selectedListId = nil
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
            settings.selectedListId = selectedListId
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
