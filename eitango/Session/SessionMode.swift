import Foundation

enum SessionMode {
    case ordered([Card_ST])
    case shuffled([Card_ST])
    var cards: [Card_ST] {
        switch self {
        case .ordered(let c): return c
        case .shuffled(let c): return c
        }
    }
}
