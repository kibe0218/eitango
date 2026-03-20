import Foundation

enum AppError {
    case network
    case auth(AuthError)
    case database(DataBaseError)
    case coreData(CoreDataError)
    case unknown
}
