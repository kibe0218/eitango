import SwiftUI
import CoreData

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


extension PlayViewModel{
    
    func ColorSetting() {
        switch colortheme {
        case 1:
            cardColor = Color(hex: "cc7a6b").opacity(0.4)
            backColor = Color(hex: "f8e8d3")
            customaccentColor = Color(hex: "8b2f3c")
            noaccentColor = Color.gray
            cardfrontColor = Color.black
            cardbackColor = Color(hex: "7b2b36")
            toggleColor = Color(hex: "8b2f3c")
            cardlistColor = Color(hex: "cc7a6b").opacity(0.6)
            cardlistmobColor = Color(hex: "cc7a6b").opacity(0.25)
            textColor = .black
        default:
            cardColor = Color.gray.opacity(colorS == .dark ? 0.4 : 0.15)
            backColor = colorS == .dark ? .black : .white
            customaccentColor = .accentColor
            noaccentColor = Color.gray
            cardfrontColor = colorS == .dark ? .white : .black
            cardbackColor = .red
            toggleColor = .accentColor
            cardlistColor = Color.gray.opacity(colorS == .dark ? 0.6 : 0.2)
            cardlistmobColor = Color.gray.opacity(colorS == .dark ? 0.25 : 0.1)
            textColor = colorS == .dark ? .white : .black
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
