import SwiftUI
import Combine

final class ListSession: ObservableObject {
    @Published var lists: [CardList] = []
}

