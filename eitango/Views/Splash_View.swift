import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var vm: PlayViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject var keyboard = KeyboardObserver()
    
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opsity = 0.5
    
    var body: some View {
        if isActive {
            HomeView()
                .environmentObject(vm)
                .environmentObject(keyboard)
        } else {
            GeometryReader { geo in
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        VStack {
                            Image("memodog")
                                .resizable()
                                .frame(width: 200, height: 200)
                            Text("memoRise")
                                .font(Font.custom("Baskerville-Bold", size: 26))
                                .foregroundColor(.black.opacity(0.80))
                        }
                        .scaleEffect(size)
                        .opacity(opsity)
                        .onAppear {
                            withAnimation(.bouncy(duration: 1.2)) {
                                self.size = 0.9
                                self.opsity = 1.0
                            }
                        }
                        Spacer()
                    }
                    .frame(alignment: .center)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                self.isActive = true
                            }
                        }
                        vm.colorS = colorScheme
                    }
                    Spacer()
                }
            }
            .background(vm.backColor.ignoresSafeArea())
        }
    }
}

