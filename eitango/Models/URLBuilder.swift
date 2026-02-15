import Foundation

struct URLBuilder {
    let baseURL: String

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
