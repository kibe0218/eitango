import Foundation
import SwiftUI

enum ColorTheme: Int, Codable {
    case monochromatic
    case normal
    
    func palette(for colorS: ColorScheme) -> Color_ST {
        switch  self {
        case .normal:
            return Color_ST(
                cardColor: Color(hex: "cc7a6b").opacity(0.4),
                backColor: Color(hex: "f8e8d3"),
                customaccentColor: Color(hex: "8b2f3c"),
                noaccentColor: Color.gray,
                cardfrontColor: Color.black,
                cardbackColor: Color(hex: "7b2b36"),
                toggleColor: Color(hex: "8b2f3c"),
                cardlistColor: Color(hex: "cc7a6b").opacity(0.6),
                cardlistmobColor: Color(hex: "cc7a6b").opacity(0.25),
                textColor : Color.black
            )
        case .monochromatic:
            return Color_ST(
                cardColor: Color.gray.opacity(colorS == .dark ? 0.4 : 0.15),
                backColor: colorS == .dark ? .black : .white,
                customaccentColor: .accentColor,
                noaccentColor: Color.gray,
                cardfrontColor:  colorS == .dark ? .white : .black,
                cardbackColor: .red,
                toggleColor: .accentColor,
                cardlistColor: Color.gray.opacity(colorS == .dark ? 0.6 : 0.2),
                cardlistmobColor: Color.gray.opacity(colorS == .dark ? 0.25 : 0.1),
                textColor: colorS == .dark ? .white : .black
        )
        }
        
    }

}

struct Color_ST {
    let cardColor: Color
    let backColor: Color
    let customaccentColor: Color
    let noaccentColor: Color
    let cardfrontColor: Color
    let cardbackColor: Color
    let toggleColor: Color
    let cardlistColor: Color
    let cardlistmobColor: Color
    let textColor: Color
}

