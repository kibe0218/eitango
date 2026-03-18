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
    
    // 最終判定
    func validateInputs() -> Bool {
        var valid = true
        
        if selectedOption == "新規作成" {
            if isValidUsername(user) == nil {
                danger_user = true
                focusedField = .user
                valid = false
            } else {
                danger_user = false
            }
        }
        
        if isValidEmail(email) == nil {
            danger_email = true
            focusedField = .email
            valid = false
        } else {
            danger_email = false
        }
        
        if isValidPassword(pass) == nil {
            danger_pass = true
            focusedField = .pass
            valid = false
        } else {
            danger_pass = false
        }
        
        return valid
    }
    
    init(
        repository: UserRepositoryProtocol,
        session: UserSession
    ) {
        self.repository = repository
        self.session = session
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        session.user = try await repository.signUp(email: email, password: password, name: name)
    }
    
    func login(email: String, password: String) async throws {
        session.user = try await repository.login(email: email, password: password)
    }
}
