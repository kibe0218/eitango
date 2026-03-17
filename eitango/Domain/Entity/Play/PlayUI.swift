import Foundation

struct PlayUI {
    var screenSlots: [ScreenCard?] = []
}

struct ScreenCard {
    var card: Card
    var cardSide: CardSide = .front
    var isFinished: Bool = false
}

