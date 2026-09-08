import Foundation

// デコード(Json->Swift)
let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()

// エンコード(Swift->Json)
let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
}()

// リクエスト送信
func sendRequest(
    url: URL,
    method: String,
    body: Data? = nil
) async throws -> Data {
    do {
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body = body {
            print("🟡 request body: \(String(data: body, encoding: .utf8) ?? "デコード失敗")")
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse
        else {
                throw DataBaseError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            break
        case 404:
            throw DataBaseError.userNotFound
        default:
            throw DataBaseError.invalidResponse
        }
        
        return data
    } catch let error as DataBaseError {
        throw error
    } catch {
        throw DataBaseError.network
    }
}

// URL作成
struct URLBuilder {
//    private let baseURL = "https://card-api-1058988137386.asia-northeast1.run.app/"
    private let baseURL = "http://localhost:8080/"
    func makeURL(
        path: String,
        queryItems: [URLQueryItem]? = nil
    ) throws -> URL {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        guard let url = components?.url else {
            fatalError("🟡 URL生成失敗")
        }
        print("🟡 \(url)")
        return url
    }
}
