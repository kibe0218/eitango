import Foundation
import FirebaseAuth

enum DBError: Error {
    case duplicatedUsername
    case invalidURL
    case network
    case invalidResponse
    case decode
    case authFailed
    case unknown
}

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
        switch AuthErrorCode(rawValue: error.code) {
        case .wrongPassword:
            self = .wrongPassword
        case .userNotFound:
            self = .userNotFound
        case .emailAlreadyInUse:
            self = .emailAlreadyInUse
        case .invalidEmail:
            self = .invalidEmail
        case .requiresRecentLogin:
            self = .requiresRecentLogin
        case .networkError:
            self = .network
        case .none:
            self = .unknown
        case .some(_):
            self = .unknown
        }
    }
}

enum CDError: Error {
    case inconsistentUserData
    case saveFailed
    case deleteFailed
}
