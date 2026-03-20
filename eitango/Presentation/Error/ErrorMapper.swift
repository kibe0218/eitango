struct ErrorMapper {
    static func map(_ error: Error) -> AppError {
        if let authError = error as? AuthError {
            return .auth(authError)
        } else if let dbError = error as? DataBaseError {
            return .database(dbError)
        } else if let coreDataError = error as? CoreDataError {
            return .coreData(coreDataError)
        } else {
            return .unknown
        }
    }
}
