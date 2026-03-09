import SwiftUI
import Combine

final class UserSession: ObservableObject {
    @Published var user: User? {
        didSet {
            userId = user?.id
        }
    }
    @Published var userId: String?
    
}
