import Foundation
import Combine

final class AuthViewModel: ObservableObject  {
    
    private let authRepository: AuthRepositoryProtocol
    private let dbRepository: DataBaseRepositoryProtocol
    
    init(
        authRepository: AuthRepositoryProtocol,
        dbRepository: DataBaseRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.dbRepository = dbRepository
    }

    func signUp(email: String, password: String, name: String) async throws {
        let uid = try await authRepository.signUp(
            provider: .email(email: email, password: password)
        )
        _ = try await dbRepository.addUser(name: name, id: uid)
    }

    func login(email: String, password: String) async throws {
        _ = try await authRepository.login(
            provider: .email(email: email, password: password)
        )
    }
    
    func delete() async throws {
        guard let uid = try await authRepository.() else {
            throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }

        // ② 先にDB側のユーザーデータを削除
        try await dbRepository.deleteUser(id: uid)

        // ③ 最後にAuth側のユーザーを削除
        try await authRepository.deleteCurrentUser()
    }
}
