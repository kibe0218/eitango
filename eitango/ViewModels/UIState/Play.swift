import Foundation
import Combine

class PlayUIState: ObservableObject {
    @Published var play: Play = Play()
    
    func reset() {
        play = Play()
    }
}


