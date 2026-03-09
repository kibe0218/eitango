import SwiftUI
import Combine

class ColorViewModel {
    let state: ColorState
    init(state: ColorState) {
        self.state = state
    }
    
    func updateTheme(theme: ColorTheme, colorScheme: ColorScheme) {
        state.currentTheme = theme
        state.palette = theme.palette(for: colorScheme)
    }
    
   
}
