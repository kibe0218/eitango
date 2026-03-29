import Foundation
import Combine

class ListViewModel: ObservableObject {
    
    private let repository: ListRepositoryProtocol
    private let session: ListSession
    private let userSession: UserSession
    private let appState: AppState

    init(
        repository: ListRepositoryProtocol,
        session: ListSession,
        userSession: UserSession,
        appState: AppState
    ) {
        self.repository = repository
        self.session = session
        self.userSession = userSession
        self.appState = appState
    }
    
    func fetchAll() async {
        do {
            session.lists = try await repository.fetchAll()
        } catch {
            appState.error = ErrorToUIAlertError(error)
        }
    }
    
    func reload() async {
        do {
            session.lists = try await repository.reload(userId: userSession.userId())
        } catch {
            appState.error = ErrorToUIAlertError(error)
        }
    }
    
    func add(list: AddListRequest) async -> CardList? {
        do {
            let newList = try await repository.add(userId: userSession.userId(), list: list)
            session.lists.append(newList)
            return newList
        } catch {
            appState.error = ErrorToUIAlertError(error)
            return nil
        }
    }
    
    func delete(id: String) async {
        do {
            try await repository.delete(userId: userSession.userId(), id: id)
            session.lists.removeAll { $0.id == id }
        } catch {
            appState.error = ErrorToUIAlertError(error)
        }
    }
}
