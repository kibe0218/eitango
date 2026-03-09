import Foundation
import FirebaseAuth

enum AuthProvider {
    case email(email: String, password: String)
}

protocol AuthRepositoryProtocol {
    func signUp(provider: AuthProvider) async throws -> String
    func login(provider: AuthProvider) async throws -> String
    func logout() async throws
    func delete() async throws
}

class AuthRepository: AuthRepositoryProtocol {
    
    //NSErrorをAuthErrorに変換してthrowする
    func wrapAuthError<T>(_ body: () async throws -> T) async throws -> T {
        do {
            return try await body()
        } catch let nsError as NSError {
            throw AuthError(error: nsError)
        }
    }
    
    //新規登録
    func signUp(provider: AuthProvider) async throws -> String {
        switch provider {
        case .email(let email, let password):
            return try await wrapAuthError {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                return result.user.uid
            }
        }
    }
    
    //ログイン
    func login(provider: AuthProvider) async throws -> String {
        switch provider {
        case .email(let email, let password):
            return try await wrapAuthError {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                return result.user.uid
            }
        }
    }
    
    //ログアウト
    func logout() async throws {
        try await wrapAuthError {
            try Auth.auth().signOut()
        }
    }
    
    //削除
    func delete() async throws {
        try await wrapAuthError {
            guard let user = Auth.auth().currentUser else {
                throw AuthError.noCurrentUser
            }
            try await user.delete()
        }
    }
    
}
