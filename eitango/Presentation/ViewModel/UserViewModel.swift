import Foundation
import Combine

class UserViewModel: ObservableObject {
    
    private let repository: UserRepositoryProtocol
    private let session: UserSession
    private let appState: AppState
    
    init(
        repository: UserRepositoryProtocol,
        session: UserSession,
        appState: AppState
    ) {
        self.repository = repository
        self.session = session
        self.appState = appState
    }
    
    @MainActor
    func fetch() {
        do {
            session.user = try repository.fetchFromCoreData()
        } catch {
            appState.error = ErrorToUIAlertError(error)
        }
    }
    
    @MainActor
    func signUp(email: String, password: String, name: String) async {
        do {
            session.user = try await repository.signUpWithEmail(email: email, password: password, name: name)
        } catch {
            appState.error = ErrorToUIAlertError(error)
        }
    }
    
    @MainActor
    func logIn(email: String, password: String) async {
        do {
            session.user = try await repository.logInWithEmail(email: email, password: password)
        } catch {
            appState.error = ErrorToUIAlertError(error)
        }
    }
    
    @MainActor
    func logout() async {
        do {
            try await repository.logOut()
            session.user = nil
        } catch {
            appState.error = ErrorToUIAlertError(error)
        }
    }
    
    @MainActor
    func delete() async {
        do {
            try await repository.delete(id: session.userId())
            session.user = nil
        } catch {
            appState.error = ErrorToUIAlertError(error)
        }
    }
}
