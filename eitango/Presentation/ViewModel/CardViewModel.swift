import Foundation
import Combine

class CardViewModel: ObservableObject {
    
    @Published var translatingCount: Int = 0
    
    private let repository: CardRepositoryProtocol
    private let session: CardSession
    private let userSession: UserSession
    private let listSession: ListSession
    private let appState: AppState
    
    init(
        repository: CardRepositoryProtocol,
        session: CardSession,
        userSession: UserSession,
        listSession: ListSession,
        appState: AppState
    ) {
        self.repository = repository
        self.session = session
        self.userSession = userSession
        self.listSession = listSession
        self.appState = appState
    }
    
    func fetchAll() {
        do {
            session.cards = try repository.fetchAll()
        } catch {
            appState.error = .alert(error.localizedDescription)
        }
    }
    
    func fetchAllBy(listId: String) {
        do {
            session.cards = try repository.fetchAllBy(listId: listId)
        } catch {
            appState.error = .alert(error.localizedDescription)
        }
    }
    
    func reload() async {
        do {
            session.cards = try await repository.reload(userId: userSession.userId())
        } catch {
            appState.error = .alert(error.localizedDescription)
        }
    }
    
    func update(listId: String, card: UpdateCardRequest) async {
        do {
            let updatedCard = try await repository.update(userId: userSession.userId(), listId: listId, card: card)
            if let index = session.cards.firstIndex(where: { $0.id == updatedCard.id }) {
                session.cards[index] = updatedCard
            }
        } catch {
            appState.error = .alert(error.localizedDescription)
        }
    }
    
    func addTranslated(listId: String, source: String, target: String, sourceWord: String) async {
        do {
            translatingCount += 1
            let newCard = try await repository.addTranslated(userId: userSession.userId(), listId: listId, source: source, target: target, sourceWord: sourceWord)
            session.cards.append(newCard)
            translatingCount -= 1
        } catch {
            appState.error = .alert(error.localizedDescription)
        }
    }
    
    func add(listId: String, card: AddCardRequest) async {
        do {
            let newCard = try await repository.add(userId: userSession.userId(), listId: listId, card: card)
            session.cards.append(newCard)
        } catch {
            appState.error = .alert(error.localizedDescription)
        }
    }
    
    func delete(listId: String, id: String) async {
        do {
            try await repository.delete(userId: userSession.userId(), listId: listId, id: id)
            session.cards.removeAll { $0.id == id }
        } catch {
            appState.error = .alert(error.localizedDescription)
        }
    }

}
