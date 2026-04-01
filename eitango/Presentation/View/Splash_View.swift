import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var vm: RootViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opsity = 0.5
    
    var body: some View {
        if isActive {
            HomeView()
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
                        print("🟡 Splash表示")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                self.isActive = true
                            }
                        }
                    }
                    Spacer()
                }
            }
            .onChange(of: colorScheme) {
                vm.colorUIState.updateForColorScheme(colorScheme)
            }
            .background(vm.colorUIState.palette.backColor.ignoresSafeArea())
        }
    }
}

