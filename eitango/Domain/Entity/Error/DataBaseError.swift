import Foundation

// DataBase
enum DataBaseError: Error {
    case userNotFound
    case duplicatedUsername
    case invalidURL
    case network
    case invalidResponse
    case decode
    case authFailed
    case unknown
}
