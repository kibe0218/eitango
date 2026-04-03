import Foundation
import AuthenticationServices
import Combine

class LogInViewModel: ObservableObject {
    
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
    func divideInputAndLogIn(identifier: String, password: String) async {
        let result = useCase.(identifier: identifier, password: password)
        if case .success(let input) = result {
            session.user = try await repository.logIn(provider: .email(email: input.identifier, password: password))
        } else {
            appState.error = .alert("アドレスまたはパスワードが違います")
        }
    }
    
    // Appleログイン
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) {
        guard let tokenData = credential.identityToken,
                  let tokenString = String(data: tokenData, encoding: .utf8) else {
                appState.error = .alert("Apple認証に失敗しました")
                return
            }

        print("🟡 token:", tokenString)

        Task {
            do {
                session.user = try await repository.signInWithApple(idToken: tokenString)
            } catch {
                appState.error = ErrorToUIAlertError(error)
            }
        }
    }
    
}
