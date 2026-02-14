import SwiftUI

enum TranslateError: Error {
    case invalidURL
    case invalidResponse
    case network(Error)
}

extension PlayViewModel{
    
    func translateTextWithGAS(
        _ text: String,
        source: String = "en",
        target: String = "ja"
    ) async throws -> String {

        let urlString = "https://script.google.com/macros/s/AKfycbxotVWEIFCz2YhhUZSdPJ7jkYlQKj2W2ya7QWRlFiGixeRaoFg7P9E75HfgQEN-GakP/exec?text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&source=\(source)&target=\(target)"

        guard let url = URL(string: urlString) else {
            print("翻訳URL生成失敗")
            throw TranslateError.invalidURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let code = json["code"] as? Int,
               code == 200,
               let translated = json["text"] as? String {
                return translated.removingPercentEncoding ?? translated
            } else {
                print("翻訳APIレスポンス異常")
                throw TranslateError.invalidResponse
            }
        } catch {
            print("通信エラー: \(error)")
            throw TranslateError.network(error)
        }
    }
    
}
