import Foundation

extension RootViewModel {
    
    //Authが成功かどうか
    var isAuthCompleted: Bool {
        if case .success = authState { return true }
        return false
    }
    
    //どっちも成功かどうか
    var isAllCompleted: Bool {
        if case .success = authState,
           case .success = dbState {
            return true
        }
        return false
    }
    
    private func handleFailedState<T: StateProtocol>(_ state: T, current: inout AppState) {
        switch state.stateCase {
        case .failed(_, let err):
            if case .error = current { return }
            current = .error(err.localizedDescription)
        default:
            break
        }
    }
    
    
    
    func updateAppState() {
        let states: [any StateProtocol] = [authState as any StateProtocol, dbState as any StateProtocol]
        states.forEach { handleFailedState($0, current: &appState) }
        switch currentFlow {
        case .addingUser:
            if isAllCompleted {
                appState = .loggedIn
                currentFlow = .none
            }
        case .loggingIn, .signingUp:
            if isAuthCompleted {
                appState = .loggedIn
                currentFlow = .none
            }
        case .loggingOut:
            if isAuthCompleted {
                appState = .loggedOut
                currentFlow = .none
            }
        case .deletingUser:
            if isAllCompleted {
                appState = .loggedOut
                currentFlow = .none
            }
        default:
            break
        }
    }
}
