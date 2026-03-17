import Foundation
import Combine

class CardViewModel: ObservableObject {
    
    @Published var translatingCount: Int = 0
    
    private let repository: CardRepositoryProtocol
    private let session: CardSession
    private let userSession: UserSession
    private let listSession: ListSession
    
    init(
        repository: CardRepositoryProtocol,
        session: CardSession,
        userSession: UserSession,
        listSession: ListSession
    ) {
        self.repository = repository
        self.session = session
        self.userSession = userSession
        self.listSession = listSession
    }
    
    func fetchAll() throws {
        session.cards = try repository.fetchAll()
    }
    
    func fetchAllBy(listId: String) throws {
        session.cards = try repository.fetchAllBy(listId: listId)
    }
    
    func reload() async throws {
        session.cards = try await repository.reload(userId: userSession.userId())
    }
    
    func update(listId: String, card: UpdateCardRequest) async throws {
        let updatedCard = try await repository.update(userId: userSession.userId(), listId: listId, card: card)
        if let index = session.cards.firstIndex(where: { $0.id == updatedCard.id }) {
            session.cards[index] = updatedCard
        }
    }
    
    func addTranslated(listId: String, source: String, target: String, sourceWord: String) async throws {
        translatingCount += 1
        let newCard = try await repository.addTranslated(userId: userSession.userId(), listId: listId, source: source, target: target, sourceWord: sourceWord)
        session.cards.append(newCard)
        translatingCount -= 1
    }
    
    func add(listId: String, card: AddCardRequest) async throws {
        let newCard = try await repository.add(userId: userSession.userId(), listId: listId, card: card)
        session.cards.append(newCard)

    }
    
    func delete(listId: String, id: String) async throws {
        try await repository.delete(userId: userSession.userId(), listId: listId, id: id)
        session.cards.removeAll { $0.id == id }
    }

}
