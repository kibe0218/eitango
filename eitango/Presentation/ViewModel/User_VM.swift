import Foundation
import Combine

class UserViewModel: ObservableObject {
    
    private let repository: UserRepositoryProtocol
    private let session: UserSession
    
    init(
        repository: UserRepositoryProtocol,
        session: UserSession
    ) {
        self.repository = repository
        self.session = session
    }
    
    func fetch() {
        do {
            session.user = try repository.fetchFromCoreData()
        } catch {
            fatalError()
        }
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        session.user = try await repository.signUp(email: email, password: password, name: name)
    }
    
    func login(email: String, password: String) async throws {
        session.user = try await repository.login(email: email, password: password)
    }
    
    func logout() async throws {
        try await repository.logout()
        session.user = nil
    }
    
    func delete() async throws {
        try await repository.delete(id: session.userId())
        session.user = nil
    }
}
