import Foundation

extension DataBaseError {
    var message: String {
        switch self {
        case .duplicatedUsername:
            return "このユーザー名は既に使用されています。他の名前で" + mouitido
        case .invalidURL:
            return "通信先URLが不正です。" + mouitido
        case .network:
            return "ネットワークエラーが発生しました。ネットワーク接続を確認してから" + mouitido
        case .invalidResponse:
            return "サーバーからの応答が不正です。申し訳ありませんがもう一度試してください。"
        case .decode:
            return "データの読み込みに失敗しました。" + mouitido
        case .authFailed:
            return "認証に失敗しました。" + mouitido
        case .unknown:
            return "保存に失敗しました。" + mouitido
        }
    }
}

