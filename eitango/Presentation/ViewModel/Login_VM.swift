//
//  StartViewModel.swift
//  memoRise
//
//  Created by kibe on 2026/03/18.
//


import Foundation
import Combine

class LoginViewModel: ObservableObject {
    
    @Published var danger: LoginSlot?
    @Published var identifier: String = ""
    @Published var password: String = ""
    
    private let repository: UserRepositoryProtocol
    private let session: UserSession
    private let useCase: LoginUseCase
    
    init(
        repository: UserRepositoryProtocol,
        session: UserSession,
        useCase: LoginUseCase
    ) {
        self.repository = repository
        self.session = session
        self.useCase = useCase
    }
    
    // 最終判定
    func validateInput() async throws {
        let result = useCase.identifierValidate(identifier: identifier, password: password)
    
        if case .success(let input) = result {
            switch input.method {
            case .email:
                session.user = try await repository.login(email: input.identifier, password: input.password)
    //        case .userName:
    //            session.user = try await repository.login(username: input.identifier, input.password: input.password)
    //
    //        case .phoneNumber:
    //            session.user = try await repository.login(phone: input.identifier, password: input.password)
    //        }
            default:
                danger = .identifier
                break
            }
            danger = nil
        } else if case .failure(let loginSlot) = result {
            danger = loginSlot
        }
    }
}
