import Foundation
import CryptoKit
import AuthenticationServices
import Combine
import FirebaseAuth

@MainActor
class AuthViewModel: NSObject, ObservableObject {
    
    private let session: UserSession
    private let useCase: AuthUseCase
    private let appState: AppState
    
    init(
        session: UserSession,
        useCase: AuthUseCase,
        appState: AppState
    ) {
        self.session = session
        self.useCase = useCase
        self.appState = appState
    }
    
    private var currentNonce: String?

    func auth(action: AuthAction?, method: AuthMethod) async {
        do {
            
            session.user = try await useCase.divideMethod(action: action, method: method)
        } catch {
            appState.error = .alert("アドレスまたはパスワードが違います")
        }
    }
    
    
// MARK: -　認証系
        
    // Apple Sign In の処理
    func handleSignInWithApple() {
        let nonce = NonceGenerator.generate(length: 32)
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Hasher.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
}

extension AuthViewModel: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        defer { currentNonce = nil }
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                appState.error = .alert("認証状態が不正です")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("🟡 Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("🟡 Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            
            Task { @MainActor in
                await auth(action: nil, method: .apple(idToken: idTokenString, nonce: nonce))
            }
        }
    }
}

// どこに表示するのか指定
extension AuthViewModel: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared
                .connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}
