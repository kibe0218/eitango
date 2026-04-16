import Foundation
import FirebaseAuth
import AuthenticationServices



protocol AuthRepositoryProtocol {
    func signUpWithEmail(email: String, password: String) async throws -> String
    func logInWithEmail(email: String, password: String) async throws -> String
    func authenticateWithApple(credential: AuthCredential) async throws -> String
    func logout() async throws
    func delete() async throws
    func currentUser() async throws -> String?
}

class AuthRepository: AuthRepositoryProtocol {
    
    // MARK: - Private Helpers
    
    // NSErrorをAuthErrorに変換してthrowする
    func wrapAuthError<T>(_ body: () async throws -> T) async throws -> T {
        do {
            return try await body()
        } catch let authError as AuthError {
            throw authError
        } catch let nsError as NSError {
            throw AuthError(error: nsError)
        } catch {
            throw AuthError.unknown
        }
    }
    // MARK: - User Authentication / Account Operations
    
    // 新規登録
    func signUpWithEmail(email: String, password: String) async throws -> String {
        return try await wrapAuthError {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user.uid
        }
    }

    // ログイン
    func logInWithEmail(email: String, password: String) async throws -> String {
        return try await wrapAuthError {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.uid
        }
    }
    
    //apple
    func authenticateWithApple(credential: AuthCredential) async throws -> String {
        return try await wrapAuthError {
            let result = try await Auth.auth().signIn(with: credential)
            return result.user.uid
        }
    }


    // 現在のユーザー
    func currentUser() async throws -> String? {
        try await wrapAuthError {
            return Auth.auth().currentUser?.uid
        }
    }

    // ログアウト
    func logout() async throws {
        try await wrapAuthError {
            try Auth.auth().signOut()
        }
    }
    
    // 削除
    func delete() async throws {
        try await wrapAuthError {
            guard let user = Auth.auth().currentUser else {
                throw AuthError.noCurrentUser
            }
            try await user.delete()
        }
    }
}
