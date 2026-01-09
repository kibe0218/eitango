import SwiftUI

struct ErrorAlertView: View {
    @EnvironmentObject var vm: PlayViewModel

    var body: some View {
        if let message = vm.error_Auth?.message ?? vm.error_User?.message {
            VStack(spacing: 20) {
                Text("エラー")
                    .foregroundStyle(vm.customaccentColor)
                    .multilineTextAlignment(.center)
                Text(message)
                    .foregroundColor(vm.cardfrontColor)
                    .multilineTextAlignment(.center)
                
                Button("OK") {
                    vm.error_Auth = nil
                    vm.error_User = nil
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
            }
            .padding()
            .frame(width: 300)
            .background(Color.blue)
            .cornerRadius(15)
            .shadow(radius: 5)
        }
    }
}
struct ErrorAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorAlertView()
            .environmentObject(PlayViewModel())
            .previewLayout(.sizeThatFits)
    }
}
