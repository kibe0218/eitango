import Foundation
import Combine

class FourCardUIState: ObservableObject {    
    @Published var screenSlots: [ScreenSlot] = Array(
        repeating: ScreenSlot(),
        count: 4
    )
    @Published var showNotification = false

    func reset() {
        screenSlots = Array(repeating: ScreenSlot, count: 4)
        showNotification = false
    }
}
