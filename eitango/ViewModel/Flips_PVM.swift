//================================================
// ♻️【Flips_PVM / カードフリップ制御】
//================================================
//
// 【役割】
// ・カードの表裏反転（flip）処理を管理
// ・表示待機時間（waittime）を制御
// ・繰り返し／終了判定のトリガーを担当
//
// 【設計方針】
// ・フリップ処理は View ではなく ViewModel に集約
// ・UI は isFlipped の状態変化だけを見る
// ・非同期処理（Task / sleep）でテンポを制御
//
// 【基本フロー】
// ① タップなどで FlippTask(i) が呼ばれる
// ② isFlipped[i] = true でカードを裏返す
// ③ waittime 分だけ待機（キャンセル可能）
// ④ 次のカード or 間違いカードを差し替え
// ⑤ 全カード処理完了で finish = true
//
// 【重要ルール】
// ・⚠️ UI 側で直接アニメーション状態を持たない
// ・⚠️ cancelFlag を必ずチェックして暴走防止
// ・⚠️ index 操作は必ず配列範囲を確認する
//
// 【補足】
// ・MistakeTask は「間違えたカードの回収係」
// ・repeatFlag が true の場合は自動で再スタート
//
//================================================


import SwiftUI
import CoreData

extension PlayViewModel{
    
    func FlippTask(i: Int) {
        DispatchQueue.main.async {
                self.isFlipped[i] = true
            }
        Task {
            let sleepInterval: UInt64 = 50_000_000 // 0.05 second
            var waited: UInt64 = 0
            let totalWait: UInt64 = UInt64(1_000_000_000 * UInt64(waittime))
            while waited < totalWait && !self.cancelFlag {
                try? await Task.sleep(nanoseconds: sleepInterval)
                waited += sleepInterval
            }
            if self.cancelFlag { return }
            let nextIndex = 4 + yy
            if i < Enlist.count && nextIndex < cards.count {
                Enlist[i] = cards[nextIndex].en ?? "-"
                Jplist[i] = cards[nextIndex].jp ?? "-"
                isFlipped[i] = false
                yy += 1
                
            } else if !mistakecardlist.isEmpty {
                let index = Int.random(in: 0..<mistakecardlist.count)
                //ランダムにindexを取得
                let randomCard = mistakecardlist[index]
                mistakecardlist.remove(at: index)
                Enlist[i] = randomCard.en
                Jplist[i] = randomCard.jp
                isFlipped[i] = false
                
            } else {
                if i < Enlist.count {
                    Enlist[i] = "✔︎"
                    Jplist[i] = "✔︎"
                    Finishlist[i] = true
                }
                yy += 1
                jj += 1
            }
            if jj >= 4 {
                finish = true
                if repeatFlag{
                    updateView()
                }
            }
        }
    }
        
    func MistakeTask(i: Int) {
        mistakecardlist.append((en: Enlist[i], jp: Jplist[i]))
        print("間違えたやつ",mistakecardlist)
        showNotification = true
    }
    
}
