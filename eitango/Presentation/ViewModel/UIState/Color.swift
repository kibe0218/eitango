import Foundation
import Combine
import SwiftUI

final class ColorUIState: ObservableObject {
    @Published var currentTheme: ColorTheme = .normal
    @Published var palette: Color_ST

    init(theme: ColorTheme = .normal, colorScheme: ColorScheme = .light) {
        self.currentTheme = theme
        self.palette = theme.palette(for: colorScheme)
    }

    func update(theme: ColorTheme, colorScheme: ColorScheme) {
        self.currentTheme = theme
        self.palette = theme.palette(for: colorScheme)
    }
    
    func updateForColorScheme(_ colorScheme: ColorScheme) {
        self.palette = currentTheme.palette(for: colorScheme)
    }
}
