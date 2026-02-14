import Foundation
import FirebaseAuth

enum AuthProvider {
    case email(email: String, password: String)
}

protocol AuthRepositoryProtocol {
    func signUp(provider: AuthProvider) async throws -> String
    func login(provider: AuthProvider) async throws -> String
    func logout() throws
    func delete() async throws
}

class AuthRepository: AuthRepositoryProtocol {
    
    //新規登録
    func signUp(provider: AuthProvider) async throws -> String {
        switch provider {
        case .email(let email, let password):
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user.uid
        }
    }
    
    //ログイン
    func login(provider: AuthProvider) async throws -> String {
        switch provider {
        case .email(let email, let password):
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.uid
        }
    }
    
    //ログアウト
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    //削除
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser
        }
        try await user.delete()
    }
    
}
