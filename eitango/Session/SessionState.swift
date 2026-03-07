import Foundation
import Combine

class SessionState: ObservableObject {
    let config: SessionConfig
    @Published var mistakeCards: [Card_ST] = []
    @Published var finish: Bool = false
    init(config: SessionConfig) {
        self.config = config
    }
}

class FourCardUIState: ObservableObject {
    let session: SessionState
    @Published var screenSlots: [ScreenSlot] = Array(
        repeating: ScreenSlot(),
        count: 4
    )
    @Published var showNotification = false

    init(session: SessionState) {
        self.session = session
    }
}


