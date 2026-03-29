import SwiftUI
import Combine


final class AppState: ObservableObject {
    @Published var error: UIError? = nil
    
}

enum UIError: Equatable {
    case alert(String)
    case toast(String)
}
