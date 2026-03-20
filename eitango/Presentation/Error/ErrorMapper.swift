struct ErrorMapper {
    static func map(_ error: Error) -> AppError {
        if let authError = error as? AuthError {
            return .auth(authError)
        } else if let dbError = error as? DataBaseError {
            return .database(dbError)
        } else if let coreDataError = error as? CoreDataError {
            return .coreData(coreDataError)
        } else {
            return .unknown(error)
        }
    }

    static func toMessage(_ error: AppError) -> String {
        switch error {
        case .auth(let e): return e.message
        case .database(let e): return e.message
        case .coreData: return "保存エラーが発生しました。"
        case .unknown: return "不明なエラーです。"
        }
    }
}
