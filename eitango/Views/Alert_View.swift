import SwiftUI

struct ErrorAlertView: View {
    @EnvironmentObject var vm: RootViewModel
    @Environment(\.colorScheme) var scheme
    
    var palette: Color_ST { vm.setting.colortheme.palette(for: scheme) }

    var body: some View {
        if vm.showErrorAlert {
            GeometryReader() { geo in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Text("エラー")
                                .font(.title)
                                .foregroundStyle(palette.customaccentColor)
                                .multilineTextAlignment(.center)
                            Spacer()
                            Text(message)
                                .foregroundColor(palette.cardfrontColor)
                                .multilineTextAlignment(.center)
                            Spacer()
                            Button("OK") {
                                vm.appState = .none
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: geo.size.width * 0.3)
                            .cornerRadius(20)
                            .glassEffect(.regular.tint(palette.customaccentColor).interactive())

                        }
                        .padding()
                        .frame(width: geo.size.width * 0.7, height: geo.size.height * 0.25, alignment: .top)
                        .background(palette.backColor)
                        .cornerRadius(50)
                        .shadow(radius: 5)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

