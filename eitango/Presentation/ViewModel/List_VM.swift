import Foundation
import Combine

class ListViewModel: ObservableObject {
    
    private let repository: ListRepositoryProtocol
    private let session: ListSession
    private let userSession: UserSession

    init(
        repository: ListRepositoryProtocol,
        session: ListSession,
        userSession: UserSession
    ) {
        self.repository = repository
        self.session = session
        self.userSession = userSession
    }
    
    func fetchAll() async throws {
        session.lists = try await repository.fetchAll()
    }
    
    func reload() async throws {
        session.lists = try await repository.reload(userId: userSession.userId())
    }
    
    func add(list: AddListRequest) async throws -> CardList {
        let newList = try await repository.add(userId: userSession.userId(), list: list)
        session.lists.append(newList)
        return newList
    }
    
    func delete(id: String) async throws {
        try await repository.delete(userId: userSession.userId(), id: id)
        session.lists.removeAll { $0.id == id }
    }
}
