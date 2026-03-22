import SwiftUI

struct ErrorAlertView: View {
    @EnvironmentObject var vm: RootViewModel
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        if case .alert(let msg) = vm.appState.error {
            GeometryReader() { geo in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Text("エラー")
                                .font(.title)
                                .foregroundStyle(vm.colorUIState.palette.customaccentColor)
                                .multilineTextAlignment(.center)
                            Spacer()
                            Text(msg)
                                .foregroundColor(vm.colorUIState.palette.cardfrontColor)
                                .multilineTextAlignment(.center)
                            Spacer()
                            Button("OK") {
                                vm.appState.error = nil
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: geo.size.width * 0.3)
                            .cornerRadius(20)
                            .glassEffect(.regular.tint(vm.colorUIState.palette.customaccentColor).interactive())

                        }
                        .padding()
                        .frame(width: geo.size.width * 0.7, height: geo.size.height * 0.25, alignment: .top)
                        .background(vm.colorUIState.palette.backColor)
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

