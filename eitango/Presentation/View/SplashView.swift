import SwiftUI

struct SplashScreenView: View {
    
    @EnvironmentObject var vm: RootViewModel
    @EnvironmentObject var colorUIState: ColorUIState

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
                        Task {
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            await MainActor.run {
                                withAnimation {
                                    self.isActive = true
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
            .onChange(of: colorScheme) {
                colorUIState.updateForColorScheme(colorScheme)
            }
            .background(colorUIState.palette.backColor.ignoresSafeArea())
        }
    }
}

