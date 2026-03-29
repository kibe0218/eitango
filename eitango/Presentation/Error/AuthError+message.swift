import Foundation

extension AuthError {
    var message: String {
        switch self {
        case .wrongPassword:
            print("🟡 message case: wrongPassword")
            return "パスワードが間違っています。\nよく確認して" + mouitido
        case .userNotFound:
            print("🟡 message case: userNotFound")
            return "ユーザーが見つかりません。\nよく確認して" + mouitido
        case .invalidEmail:
            print("🟡 message case: invalidEmail")
            return "メールアドレスの形式が正しくありません。\nよく確認して" + mouitido
        case .emailAlreadyInUse:
            print("🟡 message case: emailAlreadyInUse")
            return "そのメールアドレスは既に使用されています。\n他のアドレスで" + mouitido
        case .requiresRecentLogin:
            print("🟡 message case: requiresRecentLogin")
            return mouitido
        case .network:
            print("🟡 message case: network")
            return "ネットワークエラーです。\nインターネット接続を確認して\n" + mouitido
        case .noCurrentUser:
            return "現在ログインしていません"
        case .unknown:
            print("🟡 message case: unknown")
            return "ログインに失敗しました。\n" + mouitido
        }
    }
}
