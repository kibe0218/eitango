import SwiftUI
import FirebaseAuth

extension PlayViewModel {
    
    enum AppState {
        case none
        case loggedIn
        case launching
        case loggedOut
        case onboarding
        case error(String)
    }
    
    enum AppFlow {
        case none
        case addingUser
        case loggingIn
        case signingUp
        case loggingOut
        case deletingUser
    }

    //state変わったら呼び出される
    //現在の Flow と State から、次の AppState を決める
    func updateAppState() {
        if case .failed(_, let err) = userState {
            if case .error = appState {
                return
            }
            appState = .error(err.message)
            return
        }
        if case .failed(_, let err) = authState {
            if case .error = appState {
                return
            }
            appState = .error(err.message)
            return
        }
        
        switch currentFlow {
        case .addingUser:
            if case .success = authState,
               case .success = userState {
                appState = .loggedIn
                currentFlow = .none
            }
        case .loggingIn, .signingUp:
            if case .success = authState,
               case .success = userState {
                appState = .loggedIn
                currentFlow = .none
            }
        case .loggingOut:
            if case .success(.logoutUserAuth) = authState {
                appState = .loggedOut
                currentFlow = .none
            }
        case .deletingUser:
            if case .success(.deleteUserAuth) = authState,
               case .success(.deleteUserAPI) = userState {
                appState = .loggedOut
                currentFlow = .none
            }
        default:
            break
        }
    }
    
    var isAuthCompleted: Bool {
        if case .success = authState { return true }
        return false
    }

    var isAuthAndUserCompleted: Bool {
        if case .success = authState,
           case .success = userState {
            return true
        }
        return false
    }
    
    enum UserState {
        case idle
        case loading(UserFunc)
        case success(UserFunc)
        case failed(UserFunc, UserError)
    }
    
    enum UserFunc {
        case fetchUser
        case fetchUserFromCoreData
        case addUserAPI
        case deleteUserAPI
    }
    
    
    
    enum AuthState {
        case idle
        case loading(AuthFunc)
        case success(AuthFunc)
        case failed(AuthFunc, AuthAppError)
    }
    
    enum AuthFunc {
        case addUserAuth
        case loginUserAuth
        case logoutUserAuth
        case deleteUserAuth
    }
    
}

extension PlayViewModel.UserError {
    var message: String {
        switch self {
        case .duplicatedUsername:
            return "このユーザー名は既に使用されています"
        case .invalidURL:
            return "通信先URLが不正です"
        case .network:
            return "ネットワークエラーが発生しました"
        case .invalidResponse:
            return "サーバーからの応答が不正です"
        case .decode:
            return "データの読み込みに失敗しました"
        case .authFailed:
            return "認証に失敗しました"
        case .unknown:
            return "保存に失敗しました"
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
        case .noCurrentUser:
            return "現在ログインしていません"
        case .unknown:
            print("🟡 message case: unknown")
            return "ログインに失敗しました"
        }
    }
}

