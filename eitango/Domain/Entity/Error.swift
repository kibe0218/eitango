import Foundation
import FirebaseAuth

// DataBase
enum DBError: Error {
    case duplicatedUsername
    case invalidURL
    case network
    case invalidResponse
    case decode
    case authFailed
    case unknown
}

extension DBError {
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

// CoreData
enum CDError: Error {
    case inconsistentUserData
    case inconsistentListData
    case inconsistentCardData
    case saveFailed
    case deleteFailed
}

// URLBuilder
enum UBError: Error {
    case invalidURL
}
