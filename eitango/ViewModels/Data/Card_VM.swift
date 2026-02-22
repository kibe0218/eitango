import Foundation
import Combine

class CardViewModel: ObservableObject {
    
    private let cardRepository: CardRepositoryProtocol
    
    init(cardRepository: CardRepositoryProtocol) {
        self.cardRepository = cardRepository
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        try await cardRepository.signUp(email: email, password: password, name: name)
    }
    
    func login(email: String, password: String) async throws {
        try await cardRepository.login(email: email, password: password)
    }
    
    func delete() async throws {
        try await cardRepository.delete()
    }
}
