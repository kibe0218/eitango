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
        @Published var danger: loginType
        
        enum loginType {
            case email
            case userName
            case
        }
        
        
        private let cardSession: CardSession
        private let listSession: ListSession
        private let settingSession: SettingSession
        private let colorState: ColorUIState
        private let engine: CardNavigation
        private let uiRepository: PlayRepositoryProtocol
        init(
            playSession: PlaySession,
            playUI: PlayUI = PlayUI(),
            cardSession: CardSession,
            listSession: ListSession,
            settingSession: SettingSession,
            colorState: ColorUIState,
            engine: CardNavigation = CardNavigation(),
            uiRepository: PlayRepositoryProtocol
        ) {
            self.playSession = playSession
            self.playUI = playUI
            self.cardSession = cardSession
            self.listSession = listSession
            self.settingSession = settingSession
            self.colorState = colorState
            self.engine = engine
            self.uiRepository = uiRepository
        }

        
            if isValidUsername(user) == nil {
                danger_user = true
                focusedField = .user
                valid = false
            } else {
                danger_user = false
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
