import SwiftUI

struct ChecklistView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let i: Int
    let title: String
    let Font: Int
    let wid : Double
    let hgt : Double
    
    var body: some View {
        VStack{
            ZStack{
                ForEach(0..<7){ z in
                    Text("")
                        .frame(width: wid, height: hgt)
                        .background(Color.gray.opacity(colorScheme == .dark ? 0.25 : 0.1))
                        .cornerRadius(20)
                        .offset(y: Double(z) * 5 + 5)  // 下に少しずつずらす
                        .scaleEffect(1 - Double(z) * 0.01)  // 奥のカードを少し小さく
                        .zIndex(Double(z))  // 手前順に表示
                }
                Text(title)
                    .font(.system(size: CGFloat(Font)))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .frame(width: wid, height: hgt)
                    .background(Color.gray.opacity(colorScheme == .dark ? 0.6 : 0.2))
                    .cornerRadius(20)
                    .zIndex(100)
            }
            .frame(height: hgt + 30)  // 山札全体の高さ調整
            .padding(.bottom,10)
        }
    }
}
