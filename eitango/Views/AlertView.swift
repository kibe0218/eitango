import SwiftUI

struct ErrorAlertView: View {
    @EnvironmentObject var vm: PlayViewModel

    var body: some View {
        if let message = vm.currentErrorMessage {
            GeometryReader() { geo in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Text("エラー")
                                .font(.title)
                                .foregroundStyle(vm.customaccentColor)
                                .multilineTextAlignment(.center)
                            Spacer()
                            Text(message)
                                .foregroundColor(vm.cardfrontColor)
                                .multilineTextAlignment(.center)
                            Spacer()
                            Button("OK") {
                                vm.authState = .idle
                                vm.userState = .idle
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: geo.size.width * 0.3)
                            .cornerRadius(20)
                            .glassEffect(.regular.tint(vm.customaccentColor).interactive())

                        }
                        .padding()
                        .frame(width: geo.size.width * 0.7, height: geo.size.height * 0.25, alignment: .top)
                        .background(vm.backColor)
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

extension PlayViewModel {
    var currentErrorMessage: String? {
        if case .failed(_, let error) = userState {
            return error.message
        } else if case .failed(_, let error) = authState {
            return error.message
        } else {
            return nil
        }
    }
}
