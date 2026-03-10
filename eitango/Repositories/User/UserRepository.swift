import Foundation
import Combine

protocol UserRepositoryProtocol {
    func signUp(email: String, password: String, name: String) async throws -> User
    func login(email: String, password: String) async throws -> User
    func logout() async throws
    func delete(id: String) async throws
}

class UserRepository: UserRepositoryProtocol {
    
    let authRepository: AuthRepositoryProtocol
    let dbRepository: User_DataBaseRepositoryProtocol
    let cdRepository: User_CoreDataRepositoryProtocol
    init (
        authRepository: AuthRepositoryProtocol,
        user_dbRepository: User_DataBaseRepositoryProtocol,
        user_cdRepository: User_CoreDataRepositoryProtocol
    ) throws {
        self.authRepository = authRepository
        self.dbRepository = user_dbRepository
        self.cdRepository = user_cdRepository
    }
    
    // MARK: - Account Operations

    // 追加
    func signUp(email: String, password: String, name: String) async throws -> User {
        do {
            let uid = try await authRepository.signUp(
                provider: .email(email: email, password: password)
            )
            guard !uid.isEmpty else { throw AuthError.unknown }
            let body = AddUserRequest(id: uid, name: name)
            return try await dbRepository.add(user: body)
        } catch {
            try await authRepository.delete()
            throw error
        }
        
    }

    // ログイン
    func login(email: String, password: String) async throws -> User {
        let userId = try await authRepository.login(
            provider: .email(email: email, password: password)
        )
        return try await dbRepository.fetch(id: userId)

    }
    
    // ログアウト
    func logout() async throws {
        try await authRepository.logout()
    }
    
    // 削除
    func delete(id: String) async throws {
        try await dbRepository.delete(id: id)
        try await authRepository.delete()
        try cdRepository.delete()
    }
}
