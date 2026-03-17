import Foundation
import SwiftUI

func cardColor(
    side: CardSide,
    reverse: Bool,
    colorTheme: ColorTheme,
    colorScheme: ColorScheme
) -> Color {
    let palette = colorTheme.palette(for: colorScheme)

    switch side {
    case .front:
        return reverse ? palette.cardbackColor : palette.cardfrontColor
    case .back:
        return reverse ? palette.cardfrontColor : palette.cardbackColor
    }
}
