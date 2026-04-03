import Foundation
import AuthenticationServices


struct AuthUseCase {
    
    private let repository: UserRepositoryProtocol
    
    init(
        repository: UserRepositoryProtocol,
    ) {
        self.repository = repository
    }
    
    // デフォルトのログインの分別
    func resolveDefaultAuthMethod(identifier: String, password: String) -> DefaultAuthMethod? {
        if UserValidator.isValidEmail(identifier) != nil {
            print("🟡 email")
            return .email(email: identifier, password: password)
        } else {
            print("🟡 unknown")
            return nil
        }
    }
    
    // 成功だったらuser、失敗だったらその事実を返す
    func divideInputAndLogIn(method: AuthMethod) async throws -> User? {
        if case .input(let identifier, let password) = method {
            let defaultMethod = resolveDefaultAuthMethod(identifier: identifier, password: password)
            if case .email(let email, let password) = defaultMethod {
                return try await repository.logInWithEmail(email: email, password: password)
            } else {
                throw AuthError.invalidEmail
            }
        } else if case .apple(let idToken) = method {
            return try await repository.logInWithApple(idToken: idToken)
        }
    }
}
