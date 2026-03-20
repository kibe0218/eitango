import Foundation
import FirebaseAuth

// DataBase
enum DataBaseError: Error {
    case duplicatedUsername
    case invalidURL
    case network
    case invalidResponse
    case decode
    case authFailed
    case unknown
}

extension DBError {
    var message: String {
        switch self {
        case .duplicatedUsername:
            return "このユーザー名は既に使用されています"
        case .invalidURL:
            return "通信先URLが不正です"
        case .network:
            return "ネットワークエラーが発生しました"
        case .invalidResponse:
            return "サーバーからの応答が不正です"
        case .decode:
            return "データの読み込みに失敗しました"
        case .authFailed:
            return "認証に失敗しました"
        case .unknown:
            return "保存に失敗しました"
        }
    }
}

