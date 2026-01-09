import SwiftUI
import FirebaseAuth

extension PlayViewModel{
    
    enum AuthAppError: Error {
        case wrongPassword
        case userNotFound
        case invalidEmail
        case emailAlreadyInUse
        case requiresRecentLogin
        case unknown
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
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                let appError = AuthAppError(error: error)
                print("🟡Authエラー:", appError)
                self.error_Auth = appError
                return
            }
            
            guard let uid = result?.user.uid else {return}
            self.addUserAPI(name: name, id: uid)
        }
    }
    
    //========
    //ログイン📲
    //========
    

    func loginUser(
        email: String,
        password: String
    ) {
        print("🟡 loginUser 呼ばれたっピ")
        print("🟡 入力 email =", email)
        print("🟡 入力 password =", password)
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if let error = error as NSError? {
                let appError = AuthAppError(error: error)
                print("🟡Authエラー:", appError)
                print("🟡表示用メッセージ:", appError.message)
                self.error_Auth = AuthAppError(error: error)
                return
            }
            guard let uid = result?.user.uid else {
                print("🟡Firebase Auth.uid が nil だったっピ")
                self.error_Auth = .unknown
                return
            }
            print("🟡 login内fetch前uid =", uid)
            DispatchQueue.main.async {
                self.fetchUser(userId: uid) { userEntity in
                    print("🟡 ユーザー取得完了 id =", userEntity?.id ?? "nill")
                    self.reinit()
                    self.moveToSplash()
                }
            }
        }
    }
    
    //==========
    //ログアウト⛔️
    //==========
    
    func logoutUser() {
        Task { @MainActor in
                do {
                    try Auth.auth().signOut()
                    self.backToDefault()
                    print("🟡ログアウト完了")
                } catch let error {
                    print("🟡ログアウト失敗:", error)
                    self.error_Auth = .unknown
                }
            }
    }
    
    //======
    //削除❌
    //======
    
    func deleteUser() {
        print("🟡 delteteUser開始")
        guard let user = Auth.auth().currentUser else {
            print("🟡 deleteUser: currentUser が nil")
            return
        }
        Task { @MainActor in
            user.delete { error in
                if let error = error as NSError? {
                    let appError = AuthAppError(error: error)
                    print("🟡 FirebaseAuth ユーザー削除失敗:", appError)
                    self.error_Auth = appError
                    return
                }
                print("🟡 FirebaseAuth ユーザー削除成功")
                self.backToDefault()
            }
        }
    }
    
    //=================
    //coredataリセット🔁
    //=================
    
    func backToDefault() {
        print("🟡 backToDefault 呼ばれたっピ")
        Task { @MainActor in
            self.User = nil
            self.userid = ""
            self.logoutDeleteUserFromCoreData()
            self.selectedListId = nil
            self.shuffleFlag = false
            self.repeatFlag = false
            self.colortheme = 1
            self.waittime = 2
            saveSettings()
            self.moveToStartView()
           
        }
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
                        .environmentObject(self)
                )
                window.makeKeyAndVisible()
            }
            else {
                self.error_Auth = .unknown
            }
        }
    }

    func moveToStartView() {
        print("🟡 moveToStartView 呼ばれたっピ")
        Task { @MainActor in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(
                    rootView: StartView()
                        .environmentObject(self)
                        .environmentObject(self.keyboard)
                )
                window.makeKeyAndVisible()
            }
            else {
                self.error_Auth = .unknown
            }
        }
    }

}

extension PlayViewModel.AuthAppError {
    init(error: NSError) {
        switch error.code {
        case AuthErrorCode.wrongPassword.rawValue:
            self = .wrongPassword
        case AuthErrorCode.userNotFound.rawValue:
            self = .userNotFound
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            self = .emailAlreadyInUse
        case AuthErrorCode.invalidEmail.rawValue:
            self = .invalidEmail
        case AuthErrorCode.requiresRecentLogin.rawValue:
            self = .requiresRecentLogin
        default:
            self = .unknown
        }
    }
}

extension PlayViewModel.AuthAppError {
    var message: String {
        switch self {
        case .wrongPassword:
            return "パスワードが間違っています"
        case .userNotFound:
            return "ユーザーが見つかりません"
        case .invalidEmail:
            return "メールアドレスの形式が正しくありません"
        case .emailAlreadyInUse:
            return "そのメールアドレスは既に使用されています"
        case .requiresRecentLogin:
            return "もう一度ログインしてください"
        case .unknown:
            return "ログインに失敗しました"
        }
    }
}
