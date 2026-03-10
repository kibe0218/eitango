import Foundation
import Combine
import SwiftUI

final class RootUIState {
    let colorUIState: ColorUIState = ColorUIState()
    let playUIState: PlayUIState = PlayUIState()
}