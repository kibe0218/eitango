import Foundation
import Combine

class CardSession: ObservableObject {
    @Published var cards: [Card] = []    
}
