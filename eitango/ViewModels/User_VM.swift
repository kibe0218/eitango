import Foundation
import Combine

final class AuthViewModel: ObservableObject  {
    
    private let authRepository: AuthRepositoryProtocol
    private let dbRepository: DataBaseRepositoryProtocol
    private let cdRepository: CoreDataRepositoryProtocol
    
    init(
        authRepository: AuthRepositoryProtocol,
        dbRepository: DataBaseRepositoryProtocol,
        cdRepository: CoreDataRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.dbRepository = dbRepository
        self.cdRepository = cdRepository
    }
    
    //追加
    func signUp(email: String, password: String, name: String) async throws {
        do {
            let uid = try await authRepository.signUp(
                provider: .email(email: email, password: password)
            )
            guard !uid.isEmpty else { throw AuthError.unknown }
            _ = try await dbRepository.add_User_DB(name: name, id: uid)
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
        guard let uid = try cdRepository.fetch_User_CD()?.id else {
            throw CDError.inconsistentUserData
        }
        try await dbRepository.delete_User_DB(userId: uid)
        try cdRepository.delete_User_CD()
        try await authRepository.delete()
    }
}
