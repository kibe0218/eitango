import Foundation
import FirebaseAuth
import Combine
import AuthenticationServices

protocol UserRepositoryProtocol {
    func fetchFromCoreData() throws -> User?
    func signUpWithEmail(email: String, password: String) async throws -> User
    func logInWithEmail(email: String, password: String) async throws -> User
    func authenticateWithApple(credential: AuthCredential) async throws -> User
    func logOut() async throws
    func delete(id: String) async throws
}

class UserRepository: UserRepositoryProtocol {
    
    let authRepository: AuthRepositoryProtocol
    let dbRepository: User_DataBaseRepositoryProtocol
    let cdRepository: User_CoreDataRepositoryProtocol
    init (
        authRepository: AuthRepository,
        user_dbRepository: User_DataBaseRepository,
        user_cdRepository: User_CoreDataRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.dbRepository = user_dbRepository
        self.cdRepository = user_cdRepository
    }
    
    // MARK: - Account Operations

    // uidが存在→User 存在しない→Userを作成
    func ensureUser(uid: String) async throws -> User {
        do {
            return try await dbRepository.fetch(id: uid)
        } catch DataBaseError.userNotFound {
            try await dbRepository.add(id: uid)
            return try await dbRepository.fetch(id: uid)
        }
    }
    
    // 同期
    func fetchFromCoreData() throws -> User? {
        return try cdRepository.fetch()
    }
    
    
    // サインアップ
    func signUpWithEmail(email: String, password: String) async throws -> User {
        do {
            let uid = try await authRepository.signUpWithEmail(email: email, password: password)
            guard !uid.isEmpty else { throw AuthError.unknown }
            try await dbRepository.add(id: uid)
            return try await ensureUser(uid: uid)
        } catch {
            try await authRepository.delete()
            throw error
        }
    }
    
    // ログイン
    func logInWithEmail(email: String, password: String) async throws -> User  {
        let uid = try await authRepository.logInWithEmail(email: email, password: password)
        return try await ensureUser(uid: uid)//Authに存在するがDBに存在しないユーザーを新しく作ることができる
    }
    
    // Apple
    func authenticateWithApple(credential: AuthCredential) async throws -> User {
        let uid = try await authRepository.authenticateWithApple(credential: credential)
        return try await ensureUser(uid: uid)
    }


    // ログアウト
    func logOut() async throws {
        try await authRepository.logout()
    }
    
    // 削除
    func delete(id: String) async throws {
        try await dbRepository.delete(id: id)
        try await authRepository.delete()
        try cdRepository.delete()
    }
}
