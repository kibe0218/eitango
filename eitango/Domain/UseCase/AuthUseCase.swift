import Foundation
import AuthenticationServices
import FirebaseAuth


struct AuthUseCase {
    
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func signUpWithInput(identifier: String, password: String) async throws -> User {
        let method = try resolveInputAuthMethod(identifier: identifier, password: password)
        switch method {
        case .email:
            return try await repository.signUpWithEmail(email: identifier, password: password)
        }
    }
    
    func logInWithInput(identifier: String, password: String) async throws -> User {
        let method = try resolveInputAuthMethod(identifier: identifier, password: password)
        switch method {
        case .email:
            return try await repository.logInWithEmail(email: identifier, password: password)
        }
    }
    
    func withApple(idToken: String, nonce: String) async throws -> User {
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idToken,
            rawNonce: nonce
        )
        return try await repository.authenticateWithApple(credential: credential)
    }
    
    func auth(method: AuthMethod) async throws -> User {
        switch method {
        case .input(let action, let identifier, let password):
            switch action {
            case .signUp:
                return try await signUpWithInput(identifier: identifier, password: password)
            case .logIn:
                return try await logInWithInput(identifier: identifier, password: password)
            }
        case .apple(let idToken, let nonce):
            return try await withApple(idToken: idToken, nonce: nonce)
        }
    }
    
    // 入力値のログインの分別(今後増やす用途)
    func resolveInputAuthMethod(identifier: String, password: String) throws -> InputAuthMethod {
        if let email = UserValidator.isValidEmail(identifier) {
            print("🟡 email")
            return .email(email: email, password: password)
        } else {
            print("🟡 unknown")
            throw AuthError.invalidEmail
        }
    }
    
    
    
}
