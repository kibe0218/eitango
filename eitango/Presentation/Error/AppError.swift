import Foundation

enum AppError {
    case auth(AuthError)
    case database(DataBaseError)
    case coreData(CoreDataError)
    case unknown(Error)
}

