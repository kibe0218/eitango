import SwiftUI
import CoreData
import FirebaseAuth

extension PlayViewModel {
    
    enum UserAppError: Error {
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
            self.error_User = .invalidURL
            return
        }
        print("🟡 fetchUser リクエスト送信 URL = \(url.absoluteString)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("🟡 通信エラー: \(error)")
                self.error_User = .network
                return
            }
            guard let data = data else {
                print("🟡 データなしっピ")
                self.error_User = .unknown
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
                        self.error_User = nil
                    } catch {
                        print("🟡 保存エラー: \(error)")
                        self.error_User = .unknown
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
                    self.error_User = .decode
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
            self.error_User = nil
            return user
        } catch {
            print("🟡 fetchUserFromCoreData error: \(error.localizedDescription)")
            self.error_User = .unknown
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
        guard let url = URL(string: urlsession + "users") else {
            print("🟡 URLエラー")
            self.error_User = .invalidURL
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
                self.error_User = .network
                print("🟡 URLSession error =", error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.error_User = .invalidResponse
                return
            }
            print("🟡 statusCode =", httpResponse.statusCode)
            switch httpResponse.statusCode {
                case 201:
                    guard
                        let data,
                        let result = try? JSONDecoder().decode(AddUserResponse.self, from: data)

                    else {
                        self.error_User = .decode
                        return
                    }
                    print("🟡 デコード結果:", result)
                    DispatchQueue.main.async {
                        self.error_User = nil
                        self.fetchUser(userId: id) { userEntity in
                            print("🟡 ユーザー取得完了 id =", userEntity?.id ?? "nill")
                            self.reinit()
                            self.moveToSplash()
                        }
                    }
                case 409:
                    self.error_User = .duplicatedUsername

                default:
                    self.error_User = .unknown
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
            self.error_User = .invalidURL
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let _ = error {
                self.error_User = .network
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.error_User = .invalidResponse
                return
            }
            
            switch httpResponse.statusCode {
            case 200, 204:
                print("🟡 deleteUserAPI 成功ステータス受信")
                self.error_User = nil
                Task { @MainActor in
                    self.fetchLists(userId: userId)
                }
            default:
                self.error_User = .unknown
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
        initialSyncAllCards()
    }
    
    //================================
    //ログアウト,削除専用coredataだけ消す💨
    //================================
    
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
            self.error_User = .unknown
            return
        }
            
        do {
            try context.save()
            self.error_User = nil
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            let allUsers = try context.fetch(request)
            print("🟡 CoreData User 残数 =", allUsers.count)
        } catch {
            print("🟡 CoreData 保存失敗:", error)
            self.error_User = .unknown
        }
    }
}

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
        case .unknown:
            return "保存に失敗しました"
        }
    }
}
