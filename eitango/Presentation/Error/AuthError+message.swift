import Foundation

extension AuthError {
    var message: String {
        switch self {
        case .wrongPassword:
            print("🟡 message case: wrongPassword")
            return "パスワードが間違っています。よく確認して" + mouitido
        case .userNotFound:
            print("🟡 message case: userNotFound")
            return "ユーザーが見つかりません。よく確認して" + mouitido
        case .invalidEmail:
            print("🟡 message case: invalidEmail")
            return "メールアドレスの形式が正しくありません。よく確認して" + mouitido
        case .emailAlreadyInUse:
            print("🟡 message case: emailAlreadyInUse")
            return "そのメールアドレスは既に使用されています。他のアドレスで" + mouitido
        case .requiresRecentLogin:
            print("🟡 message case: requiresRecentLogin")
            return mouitido
        case .network:
            print("🟡 message case: network")
            return "ネットワークエラーです。インターネット接続を確認して" + mouitido
        case .noCurrentUser:
            return "現在ログインしていません"
        case .unknown:
            print("🟡 message case: unknown")
            return "ログインに失敗しました" + mouitido
        }
    }
}
