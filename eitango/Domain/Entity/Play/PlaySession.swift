import Foundation

struct PlaySession {
    var shownCount: Int = 4
    var mode: PlayMode = .ordered
    var looping: Bool = false
    var reverse: Bool = false
    var selectedListId: String?
    var mistakeCards: [String] = []
}

enum PlayMode: Int {
    case ordered = 0
    case shuffled = 1

    mutating func toggle() {
        switch self {
        case .ordered:
            self = .shuffled
        case .shuffled:
            self = .ordered
        }
    }
}

