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
    ) async throws -> String{
        print("🟡 addUser 呼ばれたっピ")
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }
    
    //========
    //ログイン📲
    //========
    
    func loginUserAuth(
        email: String,
        password: String,
    ) async throws -> String {
        print("🟡 loginUser 呼ばれたっピ")
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }
    
    //==========
    //ログアウト⛔️
    //==========
    
    func logoutUserAuth (
    ) throws -> Void {
        print("🟡 logoutUser呼ばれたっぴ")
        try Auth.auth().signOut()
    }
    
    //======
    //削除❌
    //======
    
    func deleteUserAuth() async throws {
        print("🟡 deleteUser 呼ばれたっピ")
        guard let user = Auth.auth().currentUser else {
            throw PlayViewModel.AuthAppError.noCurrentUser
        }
        try await user.delete()
    }
    
}
