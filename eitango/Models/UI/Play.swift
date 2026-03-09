import Foundation

struct Play {
    var mode: PlayMode = .ordered
    var looping: Bool = false
    var reverse: Bool = false
    var selectedListId: String?
    var finish: Bool = false
    var mistakeCards: [Card] = []
    var showNotification = false
    var screenSlots: [ScreenCard] = Array(
        repeating: ScreenCard(),
        count: 4
    )
}

enum PlayMode: Int {
    case ordered = 0
    case shuffled = 1
}

struct ScreenCard {
    var card: Card?
    var isFlipped: Bool = false
    var isFinished: Bool = false
}
