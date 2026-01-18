import SwiftUI
import FirebaseAuth

extension PlayViewModel{
    
    enum AuthAppError: Error {
        case wrongPassword
        case userNotFound
        case invalidEmail
        case emailAlreadyInUse
        case requiresRecentLogin
        case network
        case unknown
    }
    
    enum AuthState {
        case idle
        case loading(AuthFunc)
        case success(AuthFunc)
        case successWithUID(AuthFunc, uid: String)
        case failed(AuthFunc, AuthAppError)
    }
    
    enum AuthFunc {
        case addUserAuth
        case loginUserAuth
        case logoutUserAuth
        case deleteUserAuth
    }
    
    
    //=========
    //新規作成➕
    //=========
    
    func addUserAuth(
        email: String,
        password: String,
        name: String,
        completion: @escaping (String?) -> Void
    ) {
        self.authState = .loading(.addUserAuth)
        print("🟡 addUser 呼ばれたっピ")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                let appError = AuthAppError(error: error)
                self.authState = .failed(.addUserAuth, appError)
                print("🟡 Authエラー:", error)
                completion(nil)
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(nil)
                return
            }
            self.authState = .successWithUID(.addUserAuth, uid: uid)
            completion(uid)
        }
    }
    
    //========
    //ログイン📲
    //========
    
    func loginUserAuth(
        email: String,
        password: String,
        completion: @escaping (String?) -> Void
    ) {
        self.authState = .loading(.loginUserAuth)
        print("🟡 loginUser 呼ばれたっピ")
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if let error = error as NSError? {
                let appError = AuthAppError(error: error)
                print("🟡Authエラー:", appError)
                self.authState = .failed(.loginUserAuth, appError)
                completion(nil)
                return
            }
            guard let uid = result?.user.uid else {
                print("🟡Firebase Auth.uid が nil だったっピ")
                self.authState = .failed(.loginUserAuth, .unknown)
                completion(nil)
                return
            }
            self.authState = .successWithUID(.loginUserAuth, uid: uid)
            completion(uid)
            print("🟡 login success uid =", uid)
        }
    }
    
    //==========
    //ログアウト⛔️
    //==========
    
    func logoutUserAuth () {
        Task { @MainActor in
            self.authState = .loading(.logoutUserAuth)
                do {
                    try Auth.auth().signOut()
                    self.authState = .success(.logoutUserAuth)
                    print("🟡ログアウト完了")
                } catch let error {
                    print("🟡ログアウト失敗:", error)
                    self.authState = .failed(.logoutUserAuth, .unknown)
                }
            }
    }
    
    //======
    //削除❌
    //======
    
    func deleteUserAuth(
        completion: @escaping (Bool) -> Void
    ) {
        print("🟡 delteteUser開始")
        guard let user = Auth.auth().currentUser else {
            print("🟡 deleteUser: currentUser が nil")
            completion(false)
            return
        }
        self.authState = .loading(.deleteUserAuth)
        Task { @MainActor in
            user.delete { error in
                if let error = error as NSError? {
                    let appError = AuthAppError(error: error)
                    print("🟡 FirebaseAuth ユーザー削除失敗:", appError)
                    self.authState = .failed(.deleteUserAuth, appError)
                    completion(false)
                    return
                }
                print("🟡 FirebaseAuth ユーザー削除成功")
                self.authState = .success(.deleteUserAuth)
                completion(true)
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
        case NSURLErrorNotConnectedToInternet,
             NSURLErrorTimedOut,
             NSURLErrorCannotFindHost,
             NSURLErrorCannotConnectToHost:
            self = .network
        default:
            self = .unknown
        }
    }
}

extension PlayViewModel.AuthAppError {
    var message: String {
        switch self {
        case .wrongPassword:
            print("🟡 message case: wrongPassword")
            return "パスワードが間違っています"
        case .userNotFound:
            print("🟡 message case: userNotFound")
            return "ユーザーが見つかりません"
        case .invalidEmail:
            print("🟡 message case: invalidEmail")
            return "メールアドレスの形式が正しくありません"
        case .emailAlreadyInUse:
            print("🟡 message case: emailAlreadyInUse")
            return "そのメールアドレスは既に使用されています"
        case .requiresRecentLogin:
            print("🟡 message case: requiresRecentLogin")
            return "もう一度ログインしてください"
        case .network:
            print("🟡 message case: network")
            return "ネットワークエラーです"
        case .unknown:
            print("🟡 message case: unknown")
            return "ログインに失敗しました"
        }
    }
}
