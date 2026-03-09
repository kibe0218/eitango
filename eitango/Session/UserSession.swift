import SwiftUI
import Combine

final class UserSession: ObservableObject {
    @Published var user: User?
    @Published var userId: String?
}
