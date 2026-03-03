import Foundation
import Combine

class CardViewModel: ObservableObject {
    
    private let cardRepository: CardRepositoryProtocol
    
    init(cardRepository: CardRepositoryProtocol) {
        self.cardRepository = cardRepository
    }
    
    func fetchAll() throws -> [Card_ST] {
        return try cardRepository.fetchAll()
    }
    
    func fetchAllBy(listId: String) throws -> [Card_ST] {
        return try cardRepository.fetchAllBy(listId: listId)
    }
    
    func reload(cards: [Card_ST]) async throws -> [Card_ST]{
        return try await cardRepository.reload()
    }
    
    func update(listId: String, card: UpdateCardRequest) async throws -> Card_ST{
        return try await cardRepository.update(listId: listId, card: card)
    }
    
    func add(listId: String, card: AddCardRequest) async throws -> Card_ST {
        return try await cardRepository.add(listId: listId, card: card)
    }
    
    func delete(listId: String, id: String) async throws {
        return try await cardRepository.delete(listId: listId, id: id)
    }
}
