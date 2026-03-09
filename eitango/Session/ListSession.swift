import SwiftUI
import Combine

final class ListSession: ObservableObject {
    @Published var Lists: [List] = []
}

