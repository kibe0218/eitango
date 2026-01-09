import SwiftUI
import FirebaseAuth

extension Character {
    var isEmoji: Bool {
        unicodeScalars.first?.properties.isEmojiPresentation == true
        || unicodeScalars.first?.properties.isEmoji == true
    }
}

struct StartView: View {
    @EnvironmentObject var vm: PlayViewModel
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
    
    
    //============
    //文字チェック📝
    //============
    
    private func isValidUsername(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty,
              trimmed.count <= 4
        else {
            return nil
        }

        for ch in trimmed {
            if ch.isEmoji {
                continue // 絵文字OK
            }
            if ch.isLetter || ch.isNumber {
                continue // 漢字・ひらがな・英数字OK
            }
            return nil // 記号だけNG
        }

        return trimmed
    }
    
    private func isValidEmail(_ email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        let pattern =
        #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        guard !trimmed.isEmpty,
              trimmed.range(of: pattern, options: .regularExpression) != nil
        else {
            return nil
        }
        return trimmed
    }
    
    private func isValidPassword(_ password: String) -> String? {
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              trimmed.count >= 10, trimmed.count <= 64,
              trimmed.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil
        else {
            return nil
        }
        return trimmed
    }
    
    //========
    //吹き出し💬
    //========
    
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {//rectは描画可能領域
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
    
    struct SpeechBubble: View {
        @EnvironmentObject var vm: PlayViewModel
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
                                    .fill(vm.backColor)
                            )
                        Spacer()
                            .frame(width: geo.size.width * 0.1)
                    }
                    Triangle()
                        .fill(vm.backColor)
                        .frame(width: geo.size.width * 0.2, height: geo.size.height * 0.2)
                        .padding(.leading, geo.size.width * 0.05)
                        .offset(x: -0.4 * geo.size.width, y: -0.5 * geo.size.height)
                }
            }
        }
    }
    
    //=========
    //body部分📱
    //=========
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                vm.customaccentColor
                    .ignoresSafeArea()
                VStack {
                    if keyboard.keyboardHeight.isZero {
                        Spacer()
                            .frame(height: geo_height * 0.1)
                    }
                    if selectedOption == "新規作成" {
                        Text("ようこそ")
                            .foregroundStyle(vm.backColor)
                            .font(.system(size: 30))
                    }
                    else {
                        Text("おかえりなさい")
                            .foregroundStyle(vm.backColor)
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
                    .foregroundStyle(vm.backColor)
                    if keyboard.keyboardHeight.isZero {
                        Spacer()
                            .frame(height: geo_height * 0.03)
                    }
                    if selectedOption == "新規作成" {
                        Text("アカウント名(1~4文字)")
                            .font(.system(size: geo_height * 0.025))
                            .foregroundStyle(vm.backColor)
                        ZStack{
                            TextField("", text: $user)
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.center)
                                .frame(width: geo_width * 0.6, height: geo_height * 0.05)
                                .background(vm.backColor)
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
                        .foregroundStyle(vm.backColor)
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
                        .foregroundStyle(vm.backColor)
                    ZStack{
                        SecureField("", text: $pass)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: geo_width * 0.6, height: geo_height * 0.05)
                            .background(vm.backColor)
                            .cornerRadius(10)
                            .focused($focusedField, equals: .pass)
                            .submitLabel(.done)
                            .textContentType(.password)
                            .onSubmit {
                                print("🟡 onSubmit 発火したっピ")
                                if isSubmitting { return }
                                isSubmitting = true
                                if selectedOption == "ログイン" {
                                    guard isValidEmail(email) != nil else {
                                        danger_email = true
                                        focusedField = .email
                                        isSubmitting = false
                                        return
                                    }
                                    danger_email = false

                                    guard isValidPassword(pass) != nil else {
                                        danger_pass = true
                                        focusedField = .pass
                                        isSubmitting = false
                                        return
                                    }
                                    danger_pass = false
                                    vm.loginUser(email: email, password: pass)
                                    isSubmitting = false
                                } else {
                                    guard isValidUsername(user) != nil else {
                                        danger_user = true
                                        focusedField = .user
                                        isSubmitting = false
                                        return
                                    }
                                    danger_user = false

                                    guard isValidEmail(email) != nil else {
                                        danger_email = true
                                        focusedField = .email
                                        isSubmitting = false
                                        return
                                    }
                                    danger_email = false

                                    guard isValidPassword(pass) != nil else {
                                        danger_pass = true
                                        focusedField = .pass
                                        isSubmitting = false
                                        return
                                    }
                                    danger_pass = false
                                    vm.addUser(email: email, password: pass, name: user)
                                    isSubmitting = false
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
            }
            .onAppear {
                geo_height = geo.size.height
                geo_width = geo.size.width
            }
            .alert("エラー", isPresented: Binding(//isPresented:で表示管理
                get: { vm.error_User != nil || vm.error_Auth != nil },
                //alertが閉じた時の処理
                set: { _ in
                    vm.error_User = nil
                    vm.error_Auth = nil
                }
            )) {
                Button("OK") {}
                    .background(self.vm.customaccentColor)
            } message: {
                Text(vm.error_User?.message ?? vm.error_Auth?.message ?? "")
            }        }
    }
}
