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
    //🔁同期🔁
    //========
    
    func fetchUser(userId: String, completion: @escaping (UserEntity?) -> Void) {
        print("🟡 fetchUser 開始 usedrId = \(userId)")
        guard let url = URL(string:
            urlsession + "users?userId=\(userId)"
        ) else {
            print("🟡 URLエラー")
            return
        }
        print("🟡 fetchUser リクエスト送信 URL = \(url.absoluteString)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("🟡 通信エラー: \(error)")
                return
            }
            guard let data = data else {
                print("🟡 データなしっピ")
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
                    } catch {
                        print("🟡 保存エラー: \(error)")
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
        completion: @escaping (Result<String, AddUserError>) -> Void//Result<成功の型,失敗の型>
    ) {
        print("🟡 addUserAPI 開始 id = \(id), name = \(name)")
        guard let url = URL(string: urlsession + "users") else {
            print("🟡 URLエラー")
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
        print("🟡 addUserAPI リクエスト送信 URL = \(request.url?.absoluteString ?? "nil")")
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
                    print("🟡 デコード結果:", result)
                    DispatchQueue.main.async {
                        self.fetchUser(userId: id) { userEntity in
                            print("🟡 ユーザー取得完了 id =", userEntity?.id ?? "nill")
                            self.reinit()
                            self.moveToSplash()
                        }
                        completion(.success(id))
                    }
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
        print("🟡 deleteUserAPI 開始 userId = \(userId)")
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
                print("🟡 deleteUserAPI 成功ステータス受信")
                Task { @MainActor in
                    self.fetchLists(userId: userId)
                    completion(.success(()))
                }
            default:
                completion(.failure(.unknown))
            }
        }.resume()
    }
    
    //==========
    //最初の処理🈁
    //==========
    
    func reinit() {
        ColorSetting()
        loadSettings()
        self.User = self.fetchUserFromCoreData()
        self.userid = self.User?.id ?? ""
        self.userName = self.User?.name ?? ""
        fetchLists(userId: userid)
    }
    
    //===========================
    //ログアウト専用coredataだけ消す💨
    //===========================
    
    func logoutDeleteUserFromCoreData() {
        let context = PersistenceController.shared.container.viewContext
        if let oldUser = self.fetchUserFromCoreData() {
            context.delete(oldUser)
        }
        let oldLists = self.fetchListsFromCoreData()
        oldLists.forEach { context.delete($0) }
        let allCardsRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        do {
            let allCards = try context.fetch(allCardsRequest)
            allCards.forEach { context.delete($0) }
            print("🟡 全削除完了")
        } catch {
            print("🟡 CoreData fetchCards error: \(error.localizedDescription)")
        }
            
        do {
            try context.save()
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            let allUsers = try context.fetch(request)
            print("🟡 CoreData User 残数 =", allUsers.count)
        } catch {
            print("🟡 CoreData 保存失敗:", error)
        }
    }
}
