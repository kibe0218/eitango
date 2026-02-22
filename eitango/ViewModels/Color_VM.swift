import SwiftUI
import CoreData
import Combine

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}


    func EnColor(y: Bool, rev: Bool, colorScheme: ColorScheme) -> Color {
        // 表（y=false）が黒、裏（y=true）が赤
        if y {
            return cardbackColor
        } else {
            return cardfrontColor
        }
    }

    func JpColor(y: Bool, rev: Bool, colorScheme: ColorScheme) -> Color {
        // 表（y=false）が黒、裏（y=true）が赤（英日問わず統一）
        if y {
            return cardbackColor
        } else {
            return cardfrontColor
        }
    }
}
