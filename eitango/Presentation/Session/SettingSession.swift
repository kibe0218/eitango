import SwiftUI
import Combine

final class SettingSession: ObservableObject {
    @Published var setting: Setting = Setting()

    func reset() {
        setting = Setting()
    }
}

