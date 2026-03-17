import SwiftUI
import Combine

final class UserSession: ObservableObject {
    @Published var user: User?
    
    func userId() throws -> String {
        guard let id = user?.id else {
            throw AuthError.unknown
        }
        return id
    }
}

