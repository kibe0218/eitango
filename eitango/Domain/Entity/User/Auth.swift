import Foundation
import FirebaseAuth

// 今後phoneNumberとかいれたい拡張するならここ
enum InputAuthMethod {
    case email(email: String, password: String)
}

enum AuthMethod {
    case input(action: AuthAction, identifier: String, password: String)
    case apple(idToken: String, nonce: String)
}

enum AuthAction {
    case signUp
    case logIn
}
