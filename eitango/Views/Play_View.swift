import SwiftUI

struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let i: Int
    let eng: String
    let jp: String
    let isFlipped: Bool
    let reverse: Bool
    let enFont: Int
    let jpFont: Int
    let enOpacity: Double
    let jpOpacity: Double
    let wid : Double
    let hgt : Double
    let fin: Bool
    let finish: Bool
    let flip: () -> Void//返り値も引数もないことを示している（呼び出すと何か動く関数）
    let finishChose: () -> Void

    var body: some View {
        VStack {
            ZStack {
                Text(eng)
                    .font(.system(size: CGFloat(enFont)))
                    .foregroundStyle(fin ? Color.accentColor : reverse ? .red : (colorScheme == .dark ? .white : .black))
                    .frame(width: wid, height: hgt)
                    .background(Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.15))
                    .cornerRadius(20)
                    .opacity(enOpacity)
                    .scaleEffect(x: reverse ? -1 : 1, y: 1)
                Text(jp)
                    .font(.system(size: CGFloat(jpFont)))
                    .foregroundStyle(fin ? Color.accentColor : reverse ? (colorScheme == .dark ? .white : .black) : .red)
                    .frame(width: wid, height: hgt)
                    .background(Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.15))
                    .cornerRadius(20)
                    .opacity(jpOpacity)
                    .scaleEffect(x: reverse ? 1 : -1, y: 1)
            }
            .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(.easeInOut(duration: 0.5), value: isFlipped)
            .onTapGesture {
                if finish{
                    finishChose()
                }
                else{
                    flip()
                }
            }//ここで親から渡された処理を行う
        }
    }
}
