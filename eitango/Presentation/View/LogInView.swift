import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct LogInView: View {
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
                colorUIState.palette.customaccentColor
                    .ignoresSafeArea()
                    .onTapGesture {
                        focusedField = nil
                    }
                VStack {
                    
                    Spacer()
                    
                    Image("memodog")
                        .resizable()
                        .frame(width: 130, height: 130)
                    
                    ZStack {
                        if identifier.isEmpty {
                            Text("ユーザー名,メールまたは電話番号")
                                .foregroundStyle(.gray)
                                .frame(width: width * 0.8, height: height * 0.06)
                        }
                        
                        TextField("", text: $identifier)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .frame(width: width * 0.8, height: height * 0.06)
                            .focused($focusedField, equals: .user)
                            .submitLabel(.next)
                            .textContentType(.username)
                            .onSubmit {
                                focusedField = .pass
                            }
                    }
                    .background(colorUIState.palette.backColor)
                    .cornerRadius(10)
                    
                    Spacer()
                        .frame(height: height * 0.02)
                    
                    ZStack {
                        if password.isEmpty {
                            Text("パスワード")
                                .foregroundStyle(colorUIState.palette.textColor.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .frame(width: width * 0.8, height: height * 0.06)
                        }
                        
                        SecureField("", text: $password)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                            .frame(width: width * 0.8, height: height * 0.06)
                            .focused($focusedField, equals: .pass)
                            .submitLabel(.done)
                            .textContentType(.password)
                            .onSubmit {
                                print("🟡 onSubmit")
                                Task {
                                    await vm.authActions.auth(action: .login, method: .input(identifier: identifier, password: password))
                                }
                            }
                    }
                    .background(colorUIState.palette.backColor)
                    .cornerRadius(10)
                    
                    Spacer()
                        .frame(height: height * 0.02)
                    
                    AppleButton(width: width * 0.8, height: height * 0.06) {
                        vm.authActions.handleSignInWithApple()
                    }
                    .padding([.leading, .trailing, .bottom], 20)
                    
                    Spacer()
                        .frame(height: height * 0.06)
                    
                    Button("ログイン")
                    {
                        print("🟡 ログイン押")
                        Task {
                            await vm.authActions.auth(action: .login, method: .input(identifier: identifier, password: password))
                        }
                    }
                    .font(.title3)
                    .foregroundStyle(colorUIState.palette.textColor)
                    .frame(width: width * 0.8, height: height * 0.08)
                    .background(colorUIState.palette.strongaccentColor)
                    .cornerRadius(40)
                    
                    Spacer()
                    
                    Text("または")
                        .foregroundStyle(colorUIState.palette.backColor)
                    Spacer()
                        .frame(height: height * 0.03)
                    Button("新規作成") {
                        vm.authPath.append(.signUp)
                    }
                    .font(.title3)
                    .foregroundStyle(colorUIState.palette.backColor)
                    .frame(width: width * 0.8, height: height * 0.08)
                    .background(Color.clear) // ← 塗り消す
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(colorUIState.palette.strongaccentColor, lineWidth: 4)
                    )
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
                if geo.size.width > width {
                    width = geo.size.width
                }
            }
            .onChange(of: geo.size.height) {
                if geo.size.height > height {
                    height = geo.size.height
                }
            }
            .onAppear {
                print("🟡 logInView表示")
                width = geo.size.width
                height = geo.size.height
                colorUIState.updateForColorScheme(colorScheme)
            }
        }
        
    }

    struct AppleButton: View {
        
        @EnvironmentObject var colorUIState: ColorUIState
        

        var width: CGFloat
        var height: CGFloat
        var action: () -> Void
        
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: "apple.logo")
                    Text("Sign in with Apple")
                        .frame(maxWidth: .infinity)
                    
                }
                .padding(.horizontal, width * 0.1)
                .foregroundColor(.black)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: width, height: height)
                .background(colorUIState.palette.backColor)
                .cornerRadius(10)
            }
                
        }
    }
}

