import Foundation
import FirebaseAuth

// 今後phoneNumberとかいれたい拡張するならここ
enum InputAuthMethod {
    case email(email: String, password: String)
}

enum AuthMethod {
    case input
    case apple
}
