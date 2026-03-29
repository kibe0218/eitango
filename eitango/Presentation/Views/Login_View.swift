import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var vm: RootViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var identifier: String = ""
    @State private var pass: String = ""
    
    @State private var geo_height: CGFloat = 0
    @State private var geo_width: CGFloat = 0
    
    
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
                vm.colorUIState.palette.customaccentColor
                    .ignoresSafeArea()
                    .onTapGesture {
                        focusedField = nil
                    }
                VStack {
                    Spacer()
                    
                    Image("memodog")
                        .resizable()
                        .frame(width: 130, height: 130)
                    
                    TextField("ユーザー名,メールまたは電話番号", text: $identifier)
                        .foregroundStyle(vm.colorUIState.palette.textColor)
                        .multilineTextAlignment(.center)
                        .frame(width: geo_width * 0.8, height: geo_height * 0.06)
                        .background(vm.colorUIState.palette.backColor)
                        .cornerRadius(10)
                        .focused($focusedField, equals: .user)
                        .submitLabel(.next)
                        .textContentType(.username)
                        .onSubmit {
                            focusedField = .pass
                        }
                    
                    Spacer()
                        .frame(height: geo_height * 0.02)
                    
                    SecureField("パスワード", text: $pass)
                        .foregroundStyle(vm.colorUIState.palette.textColor)
                        .multilineTextAlignment(.center)
                        .frame(width: geo_width * 0.8, height: geo_height * 0.06)
                        .background(vm.colorUIState.palette.backColor)
                        .cornerRadius(10)
                        .focused($focusedField, equals: .pass)
                        .submitLabel(.done)
                        .textContentType(.password)
                        .onSubmit {
                        }
                    
                    Spacer()
                        .frame(height: geo_height * 0.06)
                    
                    Button("ログイン")
                    {
                        print("🟡 ログイン押")
                        Task {
                            await vm.loginActions.divideInputAndLogin(identifier: identifier, password: pass)
                        }
                    }
                    .font(.title3)
                    .foregroundStyle(vm.colorUIState.palette.textColor)
                    .frame(width: geo_width * 0.8, height: geo_height * 0.08)
                    .background(vm.colorUIState.palette.strongaccentColor)
                    .cornerRadius(40)
                    
                    Spacer()
                    
                    if focusedField == nil {
                        Text("または")
                            .foregroundStyle(vm.colorUIState.palette.backColor)
                        Spacer()
                            .frame(height: geo_height * 0.03)
                        Button("新規作成") {
                            Task {
                            }
                        }
                        .font(.title3)
                        .foregroundStyle(vm.colorUIState.palette.backColor)
                        .frame(width: geo_width * 0.8, height: geo_height * 0.08)
                        .background(Color.clear) // ← 塗り消す
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(vm.colorUIState.palette.strongaccentColor, lineWidth: 4)
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                ErrorAlertView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            }
            .onChange(of: colorScheme) {
                vm.colorUIState.updateForColorScheme(colorScheme)
            }
            .onAppear {
                print("🟡 LoginView表示")
                geo_height = geo.size.height
                geo_width = geo.size.width
                vm.colorUIState.updateForColorScheme(colorScheme)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = CompositionRoot.build()
        return LoginView()
            .environmentObject(vm)
            .environmentObject(vm.appState)
    }
}
