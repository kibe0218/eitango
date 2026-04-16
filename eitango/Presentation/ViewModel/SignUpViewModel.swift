import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    
    private let repository: UserRepositoryProtocol
    private let session: UserSession
    private let useCase: AuthUseCase
    private let appState: AppState
    
    init(
        repository: UserRepositoryProtocol,
        session: UserSession,
        useCase: AuthUseCase,
        appState: AppState
    ) {
        self.repository = repository
        self.session = session
        self.useCase = useCase
        self.appState = appState
    }
    
    // 最終判定
    func signUp(method: AuthMethod, name: String) async {
        do {
            session.user = try await useCase.divideMethodAndLogIn(method: method)
        } catch {
            appState.error = ErrorToUIAlertError(error)
        }
    }
}
