import SwiftUI
import Combine

final class UserSession: ObservableObject {
    @Published var userId: String?
    
    init(userId: String? = nil) {
        self.userId = userId
    }
}
