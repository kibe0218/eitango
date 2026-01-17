import SwiftUI
import CoreData
import FirebaseAuth

extension PlayViewModel.UserAppError {
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


extension PlayViewModel {
    
    enum UserAppError: Error {
        case duplicatedUsername
        case invalidURL
        case network
        case invalidResponse
        case decode
        case authFailed
        case unknown
    }
    
    enum UserState {
        case idle
        case loading(UserFunc)
        case success(UserFunc)
        case failed(UserFunc, UserAppError)
    }
    
    enum UserFunc {
        case fetchUser
        case fetchUserFromCoreData
        case addUserAPI
        case deleteUserAPI
    }
    
    //========
    //🔁同期🔁
    //========
    
    func fetchUser(userId: String, completion: @escaping (UserEntity?) -> Void) {
        print("🟡 fetchUser 開始 usedrId = \(userId)")
        guard let url = URL(string:
            urlsession + "users?userId=\(userId)"
        ) else {
            print("🟡 URLエラー")
            self.updateUserState(.failed(.fetchUser, .invalidURL))
            return
        }
        print("🟡 fetchUser リクエスト送信 URL = \(url.absoluteString)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("🟡 通信エラー: \(error)")
                self.updateUserState(.failed(.fetchUser, .network))
                return
            }
            guard let data = data else {
                print("🟡 データなしっピ")
                self.updateUserState(.failed(.fetchUser, .unknown))
                return
            }
            if let str = String(data: data, encoding: .utf8) {
                print("🟡 受信データ:", str)
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            Task { @MainActor in
                do {
                    let result = try decoder.decode(User_ST.self, from: data)
                    print("🟡 fetchUser デコード成功 → メインスレッドへ")
                    let context = PersistenceController.shared.container.viewContext
                    if let oldUser = self.fetchUserFromCoreData() {
                        context.delete(oldUser)
                        print("🟡 既存 UserEntity を1件削除")
                    }
                    // ② Firestore のカードを CoreData に保存
                    let entity = UserEntity(context: context)
                    entity.id = result.id
                    entity.name = result.name
                    entity.createdAt = result.createdAt
                    
                    do {
                        try context.save()
                        print("🟡 CoreData 保存成功")
                        self.userState = .idle
                    } catch {
                        print("🟡 保存エラー: \(error)")
                        self.updateUserState(.failed(.fetchUser, .unknown))
                    }
                    let userEntity = self.fetchUserFromCoreData()
                    self.User = userEntity
                    self.userid = userEntity?.id ?? ""
                    self.userName = userEntity?.name ?? ""
                    completion(userEntity)
                    print("🟡 代入後: \(self.userid)")
                    self.updateView()
                    print("🟡 update後: \(self.userid)")
                } catch {
                    print("🟡 decode/saveエラー:", error)
                    self.updateUserState(.failed(.fetchUser, .decode))
                }
            }

        }.resume()//通信を開始する命令
    }
    
    //============
    //📩読み込み📩
    //============
    
    func fetchUserFromCoreData() -> UserEntity? {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.fetchLimit = 1
            request.sortDescriptors = [
                NSSortDescriptor(key: "createdAt", ascending: false)
            ]

        do {
            let user = try context.fetch(request).first
            print("🟡 fetchUserFromCoreData 成功 user = \(String(describing: user))")
            return user
        } catch {
            print("🟡 fetchUserFromCoreData error: \(error.localizedDescription)")
            return nil
        }
    }
    
    //========
    //📝追加📝
    //========
    
    func addUserAPI(
        name: String,
        id: String,
    ) {
        print("🟡 addUserAPI 開始 id = \(id), name = \(name)")
        self.userState = .loading(.addUserAPI)
        guard let url = URL(string: urlsession + "users") else {
            print("🟡 URLエラー")
            self.updateUserState(.failed(.addUserAPI, .invalidURL))
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
        print("🟡 addUserAPI リクエスト送信 URL = \(request.url?.absoluteString ?? "nil")")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.updateUserState(.failed(.addUserAPI, .network))
                print("🟡 URLSession error =", error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.updateUserState(.failed(.addUserAPI, .invalidResponse))
                return
            }
            print("🟡 statusCode =", httpResponse.statusCode)
            switch httpResponse.statusCode {
                case 201:
                self.updateUserState(.success(.addUserAPI))
                    guard
                        let data,
                        let result = try? JSONDecoder().decode(AddUserResponse.self, from: data)

                    else {
                        self.updateUserState(.failed(.addUserAPI, .decode))
                        return
                    }
                    print("🟡 デコード結果:", result)
                case 409:
                self.updateUserState(.failed(.addUserAPI,.duplicatedUsername))
                default:
                self.updateUserState(.failed(.addUserAPI, .unknown))
                }

            }.resume()
        }
    
    //=======
    //❌削除❌
    //=======
    
    func deleteUserAPI(userId: String) {
        print("🟡 deleteUserAPI 開始 userId = \(userId)")
        var components = URLComponents(string: urlsession + "users")
        components?.queryItems = [
            URLQueryItem(name: "userId", value: userId)
        ]
        
        guard let url = components?.url else {
            self.updateUserState(.failed(.deleteUserAPI, .invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let _ = error {
                self.updateUserState(.failed(.deleteUserAPI, .network))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.updateUserState(.failed(.deleteUserAPI, .invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200, 204:
                print("🟡 deleteUserAPI 成功ステータス受信")
                self.updateUserState(.success(.deleteUserAPI))
                Task { @MainActor in
                    self.fetchLists(userId: userId)
                }
            default:
                self.updateUserState(.failed(.deleteUserAPI, .unknown))
            }
        }.resume()
    }
    
    //🟡 UserState 更新用 汎用関数
    func updateUserState(_ state: UserState) {
        DispatchQueue.main.async { [weak self] in
            self?.userState = state
        }
    }
}

