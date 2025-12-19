//================================================
// 💫【UIUpdate_PVM / 画面状態更新ロジック】
//================================================
//
// 【役割】
// ・🖥 UI 表示に必要な状態を一括で再計算
// ・🔁 カード・リスト・色・設定変更後の画面更新
// ・🚦 フリップ処理や待機処理のリセット制御
//
// 【基本フロー】
// ① cancelFlag を立てて進行中処理を一旦停止
// ② 各種状態（index / finish / flip）を初期化
// ③ ColorSetting() で配色を再適用
// ④ CoreData から最新データを読み込み
// ⑤ cards / Enlist / Jplist を再構築
// ⑥ UI が @Published の変更を検知して再描画
//
// 【設計方針】
// ・UI はこのファイルの関数を「きっかけ」として呼ぶだけ
// ・View 側で状態を組み立てない
// ・更新ロジックは updateView() に集約する
//
// 【重要ルール】
// ・⚠️ updateView() は状態を壊して作り直す前提
// ・⚠️ shuffle / noshuffle の分岐はここでのみ行う
// ・⚠️ index 操作は常に配列範囲チェックを行う
//
// 【補足】
// ・updateView は「画面を最初から描き直すスイッチ」
// ・状態不整合が起きたらまずここを疑う
//
//================================================

import SwiftUI
import CoreData

extension PlayViewModel{
    
    func updateView() {
        
        cancelFlag = true
        Thread.sleep(forTimeInterval: 0.07)
        yy = 0
        jj = 0
        finish = false
        ColorSetting()
        isFlipped = Array(repeating: false, count:4)
        Lists = fetchListsFromCoreData()
        if let selectedId = selectedListId,
           Lists.contains(where: { $0.id == selectedId }) {
        } else {
            selectedListId = Lists.first?.id
        }
        if let idString = selectedListId {
            Cards = fetchCardsFromCoreData(listid: idString)
        } else {
            Cards = []
        }
        if !noshuffleFlag {shuffleCards(i: shuffleFlag)}
        if let listId = selectedListId,
           Lists.contains(where: { $0.id == listId }) {
            self.enbase = Array(Cards.prefix(4)).compactMap { $0.en ?? "-" }
            self.jpbase = Array(Cards.prefix(4)).compactMap { $0.jp ?? "-" }
            Enlist = self.enbase + Array(repeating: "✔︎", count: max(0, 4 - self.enbase.count))
            Jplist = self.jpbase + Array(repeating: "✔︎", count: max(0, 4 - self.jpbase.count))
        } else {
            Enlist = Array(repeating: "", count: 4)
            Jplist = Array(repeating: "", count: 4)
            Finishlist = Array(repeating: true, count: 4)
            isFlipped = Array(repeating: false, count: 4)
        }
        for i in 0..<Enlist.count {
            if Enlist[i] == "✔︎" {
                Finishlist[i] = true
                jj += 1
            }
            else{
                Finishlist[i] = false
            }
        }
        cancelFlag = false
        saveSettings()
    }
    
    
    func shuffleCards(i: Bool){
        if i {
            Cards.shuffle()
        }
    }
    
    func EnfontSize(i: String) -> Int {
        if i.count > 15 { return 30 }
        else if i.count > 11 { return 40 }
        else { return 50 }
    }

    func JpfontSize(i: String) -> Int {
        if i.count > 7 { return 30 } else { return 40 }
    }

    func Enopacity(y: Bool, rev: Bool) -> Double {
        return y ? (rev ? 1 : 0) : (reverse ? 0 : 1)
    }

    func Jpopacity(y: Bool, rev: Bool) -> Double {
        return y ? (rev ? 0 : 1) : (reverse ? 1 : 0)
    }
    
}

