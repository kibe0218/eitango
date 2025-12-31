import SwiftUI
import FirebaseAuth

struct UserView: View {
    @EnvironmentObject var vm: PlayViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject var keyboard = KeyboardObserver()
    
    @State private var user: String = ""
    @State private var email: String = ""
    @State private var pass: String = ""
    @State private var selectedOption = "新規作成"
    
    @State private var inputuser: String = ""
    @State private var inputemail: String = ""
    
    @State private var geo_height: CGFloat = 0
    @State private var geo_width: CGFloat = 0
            
    let options = ["新規作成", "ログイン"]
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case user
        case email
        case pass
    }
    
    //=========
    //画面遷移📺
    //=========
    
    func moveToSplash() {
        print("🟡 moveToSplash 呼ばれたっピ")
        Task { @MainActor in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(
                    rootView: SplashScreenView()
                        .environmentObject(vm)
                        .environmentObject(keyboard)
                )
                window.makeKeyAndVisible()
            }
        }
    }
    
    
    //============
    //文字チェック📝
    //============
    
    private func isValidUsername(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              trimmed.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil
        else {
            return nil
        }
        return trimmed
    }
    
    private func isValidEmail(_ email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              trimmed.contains("@")
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
    //============
    //ログイン操作📲
    //============
    
    func loginUser(
        email: String,
        password: String
    ) {
        print("🟡 loginUser 呼ばれたっピ")
        print("🟡 email =", email)
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if let error = error {
                print("Authエラー",error)
                return
            }
            guard let uid = result?.user.uid else {return}
            print("🟡 Firebase Auth.uid =", uid)
            print("uidは？",uid)
            DispatchQueue.main.async {
                vm.userid = uid
                print("🟡 vm.userid にセット =", self.vm.userid)
                vm.saveSettings()
                moveToSplash()
            }
        }
    }
    
    //=========
    //新規作成➕
    //=========
    
    func addUser(
        email: String,
        password: String,
        name: String
    ) {
        print("🟡 addUser 呼ばれたっピ")
        print("🟡 email =", email)
        print("🟡 name =", name)
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Authエラー",error)
                return
            }
            
            guard let uid = result?.user.uid else {return}
            print("🟡 これを API に送る id =", uid)
            
            vm.addUserAPI(name: name, id: uid) { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        vm.userid = uid
                        print("🟡 vm.userid にセット =", self.vm.userid)
                        vm.saveSettings()
                        moveToSplash()
                    }
                case .failure(let error):
                    print("API登録失敗:", error)
                }
            }
        }
    }
    
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
                            .frame(height: max(0, geo_height * 0.23 - 50))
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
                    Spacer()
                        .frame(height: geo_height * 0.03)
                    if selectedOption == "新規作成" {
                        Text("アカウント名(1~6文字)")
                            .font(.system(size: 20))
                            .foregroundStyle(vm.backColor)
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
                                if let validUser = isValidUsername(user) {
                                    inputuser = validUser
                                    focusedField = .pass
                                } else {
                                    return
                                }
                            }
                            .onChange(of: focusedField) {
                                if focusedField == .pass || focusedField == .email {
                                    if let validUser = isValidUsername(user) {
                                        inputuser = validUser
                                    }
                                    
                                }
                            }
                        Spacer()
                            .frame(height: geo_height * 0.03)
                    }
                    Text("E-mailアドレス")
                        .font(.system(size: 20))
                        .foregroundStyle(vm.backColor)
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
                            if let validEmail = isValidEmail(email) {
                                inputemail = validEmail
                                focusedField = .pass
                            } else {
                                return
                            }
                        }
                        .onChange(of: focusedField) {
                            if focusedField == .pass {
                                if let validUser = isValidUsername(user) {
                                    inputuser = validUser
                                }
                                
                            }
                        }
                    Spacer()
                        .frame(height: geo_height * 0.03)
                    Text("パスワード(10~64文字）")
                        .font(.system(size: 20))
                        .foregroundStyle(vm.backColor)
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
                            if selectedOption == "ログイン" {
                                guard let validEmail = isValidEmail(email) else { return }
                                guard let validPass = isValidPassword(pass) else { return }
                                loginUser(email: validEmail, password: validPass)
                            } else {
                                guard let validUser = isValidUsername(inputuser) else { return }
                                guard let validEmail = isValidEmail(inputemail) else { return }
                                guard let validPass = isValidPassword(pass) else { return }
                                addUser(email: validEmail, password: validPass, name: validUser)
                            }
                        }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                geo_height = geo.size.height
                geo_width = geo.size.width
            }
        }
    }
}

#Preview {
    UserView()
        .environmentObject(PlayViewModel())
}
