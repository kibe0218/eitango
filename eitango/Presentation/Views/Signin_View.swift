import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var vm: RootViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject var keyboard = KeyboardObserver()
    
    @State private var user: String = ""
    @State private var email: String = ""
    @State private var pass: String = ""
    @State private var selectedOption = "新規作成"
    
    @State private var geo_height: CGFloat = 0
    @State private var geo_width: CGFloat = 0
    
    @State private var danger_user: Bool = false
    @State private var danger_email: Bool = false
    @State private var danger_pass: Bool = false
    
    @State private var isSubmitting = false
    
    
    let options = ["新規作成", "ログイン"]
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case user
        case email
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
                    if keyboard.keyboardHeight.isZero {
                        Spacer()
                            .frame(height: geo_height * 0.1)
                    }
                    if selectedOption == "新規作成" {
                        Text("ようこそ")
                            foregroundStyle(vm.colorUIState.palette.backColor)
                            .font(.system(size: 30))
                    }
                    else {
                        Text("おかえりなさい")
                            foregroundStyle(vm.colorUIState.palette.backColor)
                            .font(.system(size: 30))
                    }
                    if keyboard.keyboardHeight.isZero {
                        Spacer()
                            .frame(height: max(0, (geo_height * 0.18) - 30))
                    }
                    Picker("", selection: $selectedOption){
                        ForEach(options, id: \.self) {
                            option in
                            Text(option)
                                .font(.system(size: 20))
                                .cornerRadius(8)
                        }
                    }
                    .frame(width: geo_width * 0.6)
                    .pickerStyle(.segmented)
                    foregroundStyle(vm.colorUIState.palette.backColor)
                    if keyboard.keyboardHeight.isZero {
                        Spacer()
                            .frame(height: geo_height * 0.03)
                    }
                    if selectedOption == "新規作成" {
                        Text("アカウント名(1~4文字)")
                            .font(.system(size: geo_height * 0.025))
                            foregroundStyle(vm.colorUIState.palette.backColor)
                        ZStack{
                            TextField("", text: $user)
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.center)
                                .frame(width: geo_width * 0.6, height: geo_height * 0.05)
                                .background(vm.colorUIState.palette.backColor)
                                .cornerRadius(10)
                                .focused($focusedField, equals: .user)
                                .submitLabel(.next)
                                .textContentType(.username)
                                .onSubmit {
                                    guard isValidUsername(user) != nil
                                    else {
                                        danger_user = true
                                        focusedField = .user
                                        return
                                    }
                                    danger_user = false
                                    focusedField = .email
                                }
                            if danger_user {
                                HStack{
                                    Spacer()
                                    SpeechBubble()
                                        .multilineTextAlignment(.center)
                                        .frame(width: geo_width * 0.2, height: geo_height * 0.05)
                                }
                            }
                        }
                    }
                    if selectedOption == "新規作成" {
                        if keyboard.keyboardHeight.isZero {
                            Spacer()
                                .frame(height: geo_height * 0.03)
                        }
                    }
                    Text("E-mailアドレス")
                        .font(.system(size: geo_height * 0.025))
                        foregroundStyle(vm.colorUIState.palette.backColor)
                    ZStack{
                        TextField("", text: $email)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: geo_width * 0.6, height: geo_height * 0.05)
                            .background(vm.backColor)
                            .cornerRadius(10)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .textContentType(.emailAddress)
                            .onSubmit {
                                guard isValidEmail(email) != nil
                                else {
                                    danger_email = true
                                    focusedField = .email
                                    return
                                }
                                danger_email = false
                                focusedField = .pass
                            }
                        if danger_email {
                            HStack{
                                Spacer()
                                SpeechBubble()
                                    .multilineTextAlignment(.center)
                                    .frame(width: geo_width * 0.2, height: geo_height * 0.05)
                            }
                        }
                    }
                    if keyboard.keyboardHeight.isZero {
                        Spacer()
                            .frame(height: geo_height * 0.03)
                    }
                    Text("パスワード(10~64文字）")
                        .font(.system(size: geo_height * 0.025))
                        foregroundStyle(vm.colorUIState.palette.backColor)
                    ZStack{
                        SecureField("", text: $pass)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: geo_width * 0.6, height: geo_height * 0.05)
                            .background(vm.colorUIState.palette.backColor)
                            .cornerRadius(10)
                            .focused($focusedField, equals: .pass)
                            .submitLabel(.done)
                            .textContentType(.password)
                            .onSubmit {
                                Task {
                                    guard validateInputs() else { return }
                                    isSubmitting = true
                                    defer { isSubmitting = false }
                                    if selectedOption == "ログイン" {
                                        try await vm.login(email: email, password: pass)
                                    } else {
                                        try await vm.signUp(email: email, password: pass, name: user)
                                    }
                                }
                            }
                        if danger_pass {
                            HStack{
                                Spacer()
                                SpeechBubble()
                                    .multilineTextAlignment(.center)
                                    .frame(width: geo_width * 0.2, height: geo_height * 0.05)
                            }
                        }
                    }
                    if keyboard.keyboardHeight.isZero {
                        Spacer()
                            .frame(height: geo_height * 0.1)
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
                geo_height = geo.size.height
                geo_width = geo.size.width
                vm.colorUIState.updateForColorScheme(colorScheme)
            }
        }
    }
}
