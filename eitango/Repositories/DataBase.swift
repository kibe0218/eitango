import Foundation

//デコード(Json->Swift)
let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()

//エンコード(Swift->Json)
let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
}()

//リクエスト送信
func sendRequest(
    url: URL,
    method: String,
    body: Data? = nil
) async throws -> Data {
    do {
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw DBError.invalidResponse
        }
        return data
    } catch let error as DBError {
        throw error
    } catch {
        throw DBError.network
    }
}

//URL作成
struct URLBuilder {
    private let baseURL = "http://172.20.10.4:8080/"
    func makeURL(
        path: String,
        queryItems: [URLQueryItem]? = nil
    ) throws -> URL {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        guard let url = components?.url else {
            throw UBError.invalidURL
        }
        return url
    }
}
