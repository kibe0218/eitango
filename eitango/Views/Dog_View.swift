//import SwiftUI
//
//struct DogView: View {
//    @Environment(\.colorScheme) var colorScheme
//    @EnvironmentObject var vm: PlayViewModel
//    
//    @State var title: String = ""
//    @State private var x: CGFloat = 0
//    @State private var y: CGFloat = 0
//    @State private var waveOffset: CGFloat = 0
//
//    var body: some View {
//        GeometryReader { geo in
//            VStack{
//                Spacer()
//                HStack{
//                    Spacer()
//                    Image("memodog")
//                        .resizable()
//                        .frame(width: 100, height: 100)
//                        .offset(x: x, y: y)
//                        .animation(.easeInOut(duration: 1.0), value: x)
//                        .animation(.easeInOut(duration: 1.0), value: y)
//                        .onAppear {
//                            moveDog(in: geo.size)
//                        }
//                    Spacer()
//                }
//                Spacer()
//            }
//            .frame(width: geo.size.width, height: geo.size.height)
//        }
//        .background(vm.backColor.ignoresSafeArea())
//    }
//    
//    private func moveDog(in size: CGSize) {
//        let small_interval : CGFloat = 0.01
//        let step_interval: CGFloat = 1
//        let step_total = 2
//        let startX = x
//        let stertY = y
//        
//        //目的地ごとの処理
//        Timer.scheduledTimer(withTimeInterval: step_interval * CGFloat(step_total), repeats: true) { timer in
//            let targetX = CGFloat.random(in: -200...200)
//            let tergetY = CGFloat.random(in: -200...200)
//            
//            //ステップごとの処理
//            Timer.scheduledTimer(withTimeInterval: step_interval, repeats: true) { timer in
//                let step_startX = x
//                let step_startY = y
//                //let targetY = CGFloat.random(in: 0...(size.height - 100)) - size.height / 2 + 50
//                var step: CGFloat = 0
//                
//                //small_intervalごとの処理
//                Timer.scheduledTimer(withTimeInterval: small_interval, repeats: true) { timer in
//                    step += small_interval
//                    let progress = step / step_interval
//
//                    let newX = startX + (targetX - startX) * progress
//                    let baseY = startY + (targetY - startY) * progress
//                    let wave = sin(progress * .pi * 2) * 6
//
//                    withAnimation(.linear(duration: 0.02)) {
//                        x = newX
//                        y = baseY + wave
//                    }
//
//                    if step >= step_interval {
//                        timer.invalidate()
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            moveDog(in: size)
//                        }
//                    }
//                }
//            }
//        }
//        
//    }
//}
