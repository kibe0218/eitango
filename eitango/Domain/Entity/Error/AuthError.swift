import Foundation
import FirebaseAuth

// Auth
enum AuthError: Error {
    case wrongPassword
    case userNotFound
    case invalidEmail
    case emailAlreadyInUse
    case requiresRecentLogin
    case network
    case noCurrentUser
    case unknown
}

extension AuthError {
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

extension AuthError {
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
