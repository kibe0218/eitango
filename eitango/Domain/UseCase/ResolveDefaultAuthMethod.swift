import Foundation
import AuthenticationServices
import FirebaseAuth


struct AuthUseCase {
    
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    // 成功だったらuser、失敗だったらerrorを返す
    func divideMethodAndLogIn(method: AuthMethod) async throws -> User {
        switch method {
        case .input(let identifier, let password):
            let defaultMethod = try resolveDefaultAuthMethod(identifier: identifier, password: password)
            
            switch defaultMethod {
            case .email(let email, let password):
                return try await repository.logInWithEmail(email: email, password: password)
            }
            
        case .apple(let idToken, let nonce):
            let credential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: idToken,
                rawNonce: nonce
            )
            return try await repository.authenticateWithApple(credential: credential)
        }
    }

    // 入力値のログインの分別(今後増やす用途)
    func resolveDefaultAuthMethod(identifier: String, password: String) throws -> DefaultAuthMethod {
        if UserValidator.isValidEmail(identifier) != nil {
            print("🟡 email")
            return .email(email: identifier, password: password)
        } else {
            print("🟡 unknown")
            throw AuthError.invalidEmail
        }
    }
    
    
    
}
