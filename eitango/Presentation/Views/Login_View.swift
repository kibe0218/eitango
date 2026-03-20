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
    
    
    
    // 吹き出し💬
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {// rectは描画可能領域
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
    
    struct SpeechBubble: View {
        @EnvironmentObject var vm: RootViewModel
        let text = "😢"
        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    HStack{
                        Spacer()
                        Text(text)
                            .frame(width: geo.size.width * 0.7, height: geo.size.height)
                            .multilineTextAlignment(.center)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(vm.colorUIState.palette.backColor)
                            )
                        Spacer()
                            .frame(width: geo.size.width * 0.1)
                    }
                    Triangle()
                        .fill(vm.colorUIState.palette.backColor)
                        .frame(width: geo.size.width * 0.2, height: geo.size.height * 0.2)
                        .padding(.leading, geo.size.width * 0.05)
                        .offset(x: -0.4 * geo.size.width, y: -0.5 * geo.size.height)
                }
            }
        }
    }
    
    // =========
    // body部分📱
    // =========
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                vm.colorUIState.palette.customaccentColor
                    .ignoresSafeArea()
                VStack {
                    if vm.keyboard.keyboardHeight.isZero {
                        Spacer()
                    }
                    Text("ようこそ")
                        .foregroundStyle(vm.colorUIState.palette.backColor)
                        .font(.system(size: 30))

                    if vm.keyboard.keyboardHeight.isZero {
                        Spacer()
                            .frame(height: max(0, (geo_height * 0.18) - 30))
                    }
                    ZStack{
                        TextField("ユーザー名,メールまたは電話番号", text: $identifier)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: geo_width * 0.6, height: geo_height * 0.05)
                            .background(vm.colorUIState.palette.backColor)
                            .cornerRadius(10)
                            .focused($focusedField, equals: .user)
                            .submitLabel(.next)
                            .textContentType(.username)
                            .onSubmit {
                                focusedField = .pass
                            }
                        if case .identifier = vm.loginActions.danger {
                            HStack{
                                Spacer()
                                SpeechBubble()
                                    .multilineTextAlignment(.center)
                                    .frame(width: geo_width * 0.2, height: geo_height * 0.05)
                            }
                        }
                    }
                    if vm.keyboard.keyboardHeight.isZero {
                        Spacer()
                            .frame(height: geo_height * 0.03)
                    }
                    Text("パスワード(10~64文字）")
                        .font(.system(size: geo_height * 0.025))
                        foregroundStyle(vm.colorUIState.palette.backColor)
                    ZStack{
                        SecureField("パスワード(10~64文字)", text: $pass)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: geo_width * 0.6, height: geo_height * 0.05)
                            .background(vm.colorUIState.palette.backColor)
                            .cornerRadius(10)
                            .focused($focusedField, equals: .pass)
                            .submitLabel(.done)
                            .textContentType(.password)
                            .onSubmit {
                            }
                        if case .password = vm.loginActions.danger {
                            HStack{
                                Spacer()
                                SpeechBubble()
                                    .multilineTextAlignment(.center)
                                    .frame(width: geo_width * 0.2, height: geo_height * 0.05)
                            }
                        }
                    }
                    Button("ログイン") {
                        Task {
                            await vm.loginActions.validateInput()
                        }
                    }
                    if vm.keyboard.keyboardHeight.isZero {
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .onChange(of: colorScheme) {
                vm.colorUIState.updateForColorScheme(colorScheme)
            }
            .onAppear {
                geo_height = geo.size.height
                geo_width = geo.size.width
                vm.colorUIState.updateForColorScheme(colorScheme)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
