import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct EmailSignUpView: View {
    @EnvironmentObject var vm: RootViewModel
    @EnvironmentObject var colorUIState: ColorUIState
    @EnvironmentObject var keyboard: KeyboardObserver
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var identifier: String = ""
    @State private var password: String = ""
    
    
    @State private var width: CGFloat = 0
    @State private var height: CGFloat = 0
    
    @FocusState private var focusedField: Field?
    enum Field {
        case user
        case pass
    }
    
    // =========
    // body部分📱
    // =========
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                colorUIState.palette.backColor
                    .ignoresSafeArea()
                    .onTapGesture {
                        focusedField = nil
                    }
                VStack {
                    
                    Spacer()
                        .frame(height: height * 0.25)
                    
                    Text("memoRiseに登録")
                        .font(Font.largeTitle.bold())
                        .foregroundStyle(.black)
                    
                    
                    Image("memodog")
                        .resizable()
                        .frame(width: 130, height: 130)
                    
                    Spacer().frame(height: height * 0.02)
                    
                    CustomButton(systemName: "envelope", title: "メールで登録", width: width * 0.8, height: height * 0.08) {
                        vm.authPath.append(.emailSignUp)
                    }
                    Spacer().frame(height: height * 0.02)
                    CustomButton(systemName: "apple.logo", title: "Sign up with Apple", width: width * 0.8, height: height * 0.08) {
                        vm.authActions.handleSignInWithApple()
                    }
                    .padding([.leading, .trailing, .bottom], 20)
                    
                    Spacer()
                        .frame(height: height * 0.06)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                ErrorAlertView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            }
            .ignoresSafeArea(.keyboard)
            .onChange(of: colorScheme) {
                colorUIState.updateForColorScheme(colorScheme)
            }
            .onChange(of: geo.size.width) {
                print("🟡 geo.size.width: \(geo.size.width)")
                if geo.size.width > width {
                    width = geo.size.width
                }
            }
            .onChange(of: geo.size.height) {
                print("🟡 geo.size.height: \(geo.size.height)")
                if geo.size.height > height {
                    height = geo.size.height
                }
            }
            .onAppear {
                width = geo.size.width
                height = geo.size.height
                print("🟡 signupView表示")
                colorUIState.updateForColorScheme(colorScheme)
            }
        }
    }

    struct CustomButton: View {
        
        @EnvironmentObject var colorUIState: ColorUIState
        
        var systemName: String
        var title: String
        var width: CGFloat
        var height: CGFloat
        var action: () -> Void
        
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: systemName)
                    
                    Text(title)
                        .frame(maxWidth: .infinity)
                    
                }
                .padding(20)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: width, height: height)
                .background(colorUIState.palette.customaccentColor)
                .cornerRadius(40)
                .background(Color.clear) // ← 塗り消す
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(colorUIState.palette.customaccentColor.opacity(0.3), lineWidth: 8)
                )
            }
        }
    }
}
