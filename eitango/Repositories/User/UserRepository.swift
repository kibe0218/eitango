import Foundation
import Combine

protocol UserRepositoryProtocol {
    func signUp(email: String, password: String, name: String) async throws
    func login(email: String, password: String) async throws
    func delete() async throws
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
    
    //追加
    func signUp(email: String, password: String, name: String) async throws {
        do {
            let uid = try await authRepository.signUp(
                provider: .email(email: email, password: password)
            )
            guard !uid.isEmpty else { throw AuthError.unknown }
            let body = AddUserRequest(id: uid, name: name)
            _ = try await dbRepository.add(user: body)
        } catch {
            try await authRepository.delete()
        }
        
    }

    //ログイン
    func login(email: String, password: String) async throws {
        _ = try await authRepository.login(
            provider: .email(email: email, password: password)
        )
    }
    
    //削除
    func delete() async throws {
        try await dbRepository.delete()
        try cdRepository.delete()
        try await authRepository.delete()
    }
}
