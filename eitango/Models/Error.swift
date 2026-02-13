import Foundation

enum UserError: Error {
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
