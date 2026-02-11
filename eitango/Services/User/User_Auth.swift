import SwiftUI
import FirebaseAuth

extension PlayViewModel{
    
    //=========
    //新規作成➕
    //=========
    
    func addUserAuth(
        email: String,
        password: String,
        name: String,
        completion: @escaping (String?) -> Void
    ) {
        self.authState = .loading(.addUserAuth)
        print("🟡 addUser 呼ばれたっピ")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                let appError = AuthAppError(error: error)
                self.authState = .failed(.addUserAuth, appError)
                print("🟡 Authエラー:", error)
                completion(nil)
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(nil)
                return
            }
            self.authState = .success(.addUserAuth)
            completion(uid)
        }
    }
    
    //========
    //ログイン📲
    //========
    
    func loginUserAuth(
        email: String,
        password: String,
        completion: @escaping (String?) -> Void
    ) {
        self.authState = .loading(.loginUserAuth)
        print("🟡 loginUser 呼ばれたっピ")
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if let error = error as NSError? {
                let appError = AuthAppError(error: error)
                print("🟡Authエラー:", appError)
                self.authState = .failed(.loginUserAuth, appError)
                completion(nil)
                return
            }
            guard let uid = result?.user.uid else {
                print("🟡Firebase Auth.uid が nil だったっピ")
                self.authState = .failed(.loginUserAuth, .unknown)
                completion(nil)
                return
            }
            self.authState = .success(.loginUserAuth)
            completion(uid)
            print("🟡 login success uid =", uid)
        }
    }
    
    //==========
    //ログアウト⛔️
    //==========
    
    func logoutUserAuth () {
        Task { @MainActor in
            self.authState = .loading(.logoutUserAuth)
                do {
                    try Auth.auth().signOut()
                    self.authState = .success(.logoutUserAuth)
                    print("🟡ログアウト完了")
                } catch let error {
                    print("🟡ログアウト失敗:", error)
                    self.authState = .failed(.logoutUserAuth, .unknown)
                }
            }
    }
    
    //======
    //削除❌
    //======
    
    func deleteUserAuth(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("🟡deleteUser: currentUser が nil")
            completion(false)
            return
        }

        user.delete { error in
            if let error = error {
                print("🟡deleteUser失敗:", error)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
