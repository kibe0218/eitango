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
