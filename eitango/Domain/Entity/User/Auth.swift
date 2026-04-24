import Foundation
import FirebaseAuth

enum AuthAction {
    case login
    case signup
}

enum AuthMethod: Equatable {
    case input(identifier: String, password: String)
    case apple(idToken: String, nonce: String)
}

// 今後phoneNumberとかいれたい
enum DefaultAuthMethod {
    case email(email: String, password: String)
}
