import Foundation

enum AuthMethod: Equatable {
    case input(identifier: String, password: String)
    case apple(idToken: String)
}

enum DefaultAuthMethod {
    case email(email: String, password: String)
}
