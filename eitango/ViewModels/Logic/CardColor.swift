import Foundation
import SwiftUI

func cardColor(
    isEnglish: Bool,
    reverse: Bool,
    colorTheme: ColorTheme,
    colorScheme: ColorScheme
) -> Color {
    let palette = colorTheme.palette(for: colorScheme)

    if isEnglish {
        return reverse ? palette.cardbackColor : palette.cardfrontColor
    } else {
        return reverse ? palette.cardfrontColor : palette.cardbackColor
    }
}
