import Foundation

extension DataBaseError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "ユーザーを見つけることができませんでした。\n" + mouitido
        case .duplicatedUsername:
            return "このユーザー名は既に使用されています。\n他の名前で" + mouitido
        case .invalidURL:
            return "通信先URLが不正です。" + mouitido
        case .network:
            return "ネットワークエラーが発生しました。\nネットワーク接続を確認してから\n" + mouitido
        case .invalidResponse:
            return "サーバーからの応答が不正です。\n" + mouitido
        case .decode:
            return "データの読み込みに失敗しました。\n" + mouitido
        case .authFailed:
            return "認証に失敗しました。\n" + mouitido
        case .unknown:
            return "保存に失敗しました。\n" + mouitido
        }
    }
}

