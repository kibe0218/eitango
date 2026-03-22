import SwiftUI
import Combine

enum TranslateError: Error {
    case invalidURL
    case invalidResponse
    case network(Error)
}

protocol TranslateRepositoryProtocol {
    func translateTextWithGAS (text: String, source: String, target: String) async throws -> String
}

class Card_GoogleAppScriptTranslate: TranslateRepositoryProtocol {
    
    func translateTextWithGAS(
        text: String,
        source: String,
        target: String
    ) async throws -> String {
        let encodedWord = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https:// script.google.com/macros/s/AKfycbxotVWEIFCz2YhhUZSdPJ7jkYlQKj2W2ya7QWRlFiGixeRaoFg7P9E75HfgQEN-GakP/exec?text=\(encodedWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&source=\(source)&target=\(target)"
        
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
