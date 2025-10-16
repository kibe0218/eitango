import SwiftUI
import Combine

final class PlayViewModel: ObservableObject {
    @Published var English: [String] = [
        "apple", "banana", "orange", "grape",
        "peach", "melon", "lemon", "pineapple",
        "strawberry", "cherry", "watermelon", "kiwi"
    ]
    @Published var Japanese: [String] = [
        "りんご", "バナナ", "オレンジ", "ぶどう",
        "もも", "メロン", "レモン", "パイナップル",
        "いちご", "さくらんぼ", "すいか", "キウイ"
    ]
    @Published var Enlist: [String] = []
    @Published var Jplist: [String] = []
    @Published var Finishlist: [Bool] = [false, false, false, false]
    @Published var tangotyou: [String] = ["単語帳1", "単語帳2", "単語帳3", "単語帳4"]
    
    @Published var reverse = false
    @Published var number = 0
    @Published var waittime = 2
    @Published var isFlipped: [Bool] = [false, false, false, false]
    @Published var yy = 1
    @Published var jj = 0
    @Published var finish = false
    
    init() {
            // English / Japanese の最初4単語をコピーして初期化
            Enlist = Array(English.prefix(4))
            Jplist = Array(Japanese.prefix(4))
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

    func FlippTask(i: Int) {
        withAnimation {
            isFlipped[i] = reverse ? false : true
        }
        Task {
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * UInt64(waittime)))
            if 4 + yy < English.count {
                Enlist[i] = English[4 + yy]
                Jplist[i] = Japanese[4 + yy]
                isFlipped[i] = reverse ? true : false
                yy += 1
            } else {
                Enlist[i] = "-"
                Jplist[i] = "-"
                Finishlist[i] = true
                jj += 1
            }
            if jj >= 4 {
                finish = true
            }
        }
    }

    func finishChose(i: Int) {
        Finishlist[i] = true
    }
}
