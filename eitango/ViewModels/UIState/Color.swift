import Foundation
import Combine
import SwiftUI

final class ColorState: ObservableObject {
    @Published var currentTheme: ColorTheme = .normal
    @Published var palette: Color_ST
    init(theme: ColorTheme = .normal, colorScheme: ColorScheme = .light) {
        self.currentTheme = theme
        self.palette = theme.palette(for: colorScheme)
    }
}
