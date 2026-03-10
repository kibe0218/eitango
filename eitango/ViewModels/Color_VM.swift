import SwiftUI
import Combine

class ColorViewModel {
    let state: ColorUIState
    init(state: ColorUIState) {
        self.state = state
    }
    
    func updateTheme(theme: ColorTheme, colorScheme: ColorScheme) {
        state.currentTheme = theme
        state.palette = theme.palette(for: colorScheme)
    }
   
}
