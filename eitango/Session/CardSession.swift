import Foundation
import Combine

class SessionState: ObservableObject {
    let mode: SessionMode
    @Published var cards: [Card] = []
    @Published var mistakeCards: [Card] = []
    @Published var finish: Bool = false
    @Published var looping: Bool = false
    @Published var reverse: Bool = false
    
    init(mode: SessionMode) {
        self.mode = mode
    }
    
    func reset() {
        self.cards = []
        self.mistakeCards = []
        self.finish = false
        self.looping = false
        self.reverse = false
    }
}
