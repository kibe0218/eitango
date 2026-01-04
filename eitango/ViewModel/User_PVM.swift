import SwiftUI
import CoreData
import FirebaseAuth

extension PlayViewModel {
    
    enum AddUserError: Error {
        case duplicatedUsername
        case invalidURL
        case network
        case invalidResponse
        case decode
        case unknown
    }
    
    //========
    //📝追加📝
    //========
    
    func addUserAPI(
        name: String,
        id: String,
        completion: @escaping (Result<String, AddUserError>) -> Void//Result<成功の型,失敗の型>
    ) {
        guard let url = URL(string: urlsession + "users") else {
            print("URLエラー")
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "id": id,
            "name": name,
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        print("🟡 API送信直前 id =", id)
        print("🟡 リクエストURL =", request.url?.absoluteString ?? "nil")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.network))
                print("🟡 URLSession error =", error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            print("🟡 statusCode =", httpResponse.statusCode)
            switch httpResponse.statusCode {
                case 201:
                    guard
                        let data,
                        let result = try? JSONDecoder().decode(AddUserResponse.self, from: data)
                    else {
                        completion(.failure(.decode))
                        return
                    }
                    completion(.success(result.id))

                case 409:
                    completion(.failure(.duplicatedUsername))

                default:
                    completion(.failure(.unknown))
                }

            }.resume()
        }
    
    //=======
    //❌削除❌
    //=======
    
    func deleteUserAPI(userId: String, completion: @escaping (Result<Void, AddUserError>) -> Void) {
        var components = URLComponents(string: urlsession + "users")
        components?.queryItems = [
            URLQueryItem(name: "userId", value: userId)
        ]
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let _ = error {
                completion(.failure(.network))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200, 204:
                Task { @MainActor in
                    self.fetchLists(userId: userId)
                    completion(.success(()))
                }
            default:
                completion(.failure(.unknown))
            }
        }.resume()
    }
    
}
