import Foundation
import Combine

class UserViewModel: ObservableObject {
    
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        try await userRepository.signUp(email: email, password: password, name: name)
    }
    
    func login(email: String, password: String) async throws {
        try await userRepository.login(email: email, password: password)
    }
    
    func delete() async throws {
        try await userRepository.delete()
    }
}
