import SwiftUI
import CoreData
import Combine

class SessionState: ObservableObject {
    @Published var isFlipped: [Bool] = []
    @Published var finish = false
    @Published var showNotification = false
}

class SessionEngine {

    func nextCard(
        currentIndex: Int,
        yy: inout Int,
        jj: inout Int,
        data: inout SessionData
    ) {
        // 次カード決定ロジックだけ
        
    }
}

struct DelayController {
    static func wait(seconds: Double) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}




class LearningSessionEngine: ObservableObject {
    
    func FlippTask(i: Int) {
        DispatchQueue.main.async {
            self.isFlipped[i] = true
        }
        Task {
            let sleepInterval: UInt64 = 50_000_000 // 0.05 second
            var waited: UInt64 = 0
            let totalWait: UInt64 = UInt64(1_000_000_000 * UInt64(self.setting?.waitTime))
            while waited < totalWait && !self.cancelFlag {
                try? await Task.sleep(nanoseconds: sleepInterval)
                waited += sleepInterval
            }
            if self.cancelFlag { return }
            let nextIndex = 4 + yy
            if i < Enlist.count && nextIndex < Cards.count {
                Enlist[i] = Cards[nextIndex].en ?? "-"
                Jplist[i] = Cards[nextIndex].jp ?? "-"
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
        print("🟡間違えたやつ",mistakecardlist)
        showNotification = true
    }
    
}
