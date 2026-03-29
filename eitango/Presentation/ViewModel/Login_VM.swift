//
//  StartViewModel.swift
//  memoRise
//
//  Created by kibe on 2026/03/18.
//


import Foundation
import Combine

class LoginViewModel: ObservableObject {
    
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
    func divideInputAndLogin(identifier: String, password: String) async {
        let result = useCase.resolveAuthMethod(identifier: identifier, password: password)
        if case .success(let input) = result {
            switch input.method {
            case .email:
                do {
                    session.user = try await repository.login(email: input.identifier, password: input.password)
                } catch {
                    print("🟡 catch:")
                    appState.error = ErrorToUIAlertError(error)
                }
            case .userName:
                appState.error = .alert("未実装です")
                
            case .phoneNumber:
                appState.error = .alert("未実装です")
            }
        } else {
            appState.error = .alert("アドレスまたはパスワードが違います")
        }
    }
}
