import SwiftUI
import CoreData

extension PlayViewModel{
    
    func updateView() {
        cancelFlag = true
        Thread.sleep(forTimeInterval: 0.07)
        // 0.1秒待つ
        yy = 0
        jj = 0
        finish = false
        
        ColorSetting()
        isFlipped = Array(repeating: false, count:4)
        tangotyou = loadCardList()
            .sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
            .compactMap { $0.title ?? "" }
        if tangotyou.indices.contains(number) && numberFlag{
            //containsでそれが範囲に含まれるかチェック
            //tangotyou は 現在の単語リストタイトルの配列
            //number は 現在表示しているリストのインデックス
            //.indices は 0..<(配列の要素数) の範囲 を返す
            title = tangotyou[number]
            numberFlag = false
        }else if numberFlag || !tangotyou.indices.contains(number){
            title = tangotyou.first ?? ""
            numberFlag = false
        }
        cards = loadCards(title: title)
        if !noshuffleFlag {shuffleCards(i: shuffleFlag)}
        self.enbase = Array(cards.prefix(4)).compactMap { $0.en ?? "-" }
        self.jpbase = Array(cards.prefix(4)).compactMap { $0.jp ?? "-" }
        Enlist = self.enbase + Array(repeating: "✔︎", count: max(0, 4 - self.enbase.count))
        Jplist = self.jpbase + Array(repeating: "✔︎", count: max(0, 4 - self.jpbase.count))
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
        print("待機：\(waittime)")
    }
    
    
    func shuffleCards(i: Bool){
        if i {
            cards.shuffle()
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

