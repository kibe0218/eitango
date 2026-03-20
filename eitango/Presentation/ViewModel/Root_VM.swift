import SwiftUI
import Combine
import CoreData

final class RootViewModel: ObservableObject {
    
    // App-wide UI state (View は基本これだけを見る)
    @Published var colorUIState: ColorUIState
    
    // App-wide helpers
    @Published var keyboard = KeyboardObserver()
    
    // Screen Observer
    @Published var path: [Screen] = []

    // App-wide sessions (View は直接見ない前提 / Actions が参照)
    var userSession: UserSession
    var listSession: ListSession
    var cardSession: CardSession
    var settingSession: SettingSession
    var playSession: PlaySession
    
    // Actions / Feature ViewModels (UIState を更新する側)
    var userActions: UserViewModel
    var listActions: ListViewModel
    var cardActions: CardViewModel
    var playActions: PlayViewModel
    var loginActions: LoginViewModel



    init(
        userSession: UserSession,
        listSession: ListSession,
        cardSession: CardSession,
        settingSession: SettingSession,
        playSession: PlaySession,
        colorUIState: ColorUIState,
        userRepository: UserRepositoryProtocol,
        listRepository: ListRepositoryProtocol,
        cardRepository: CardRepositoryProtocol,
        playRepository: PlayRepositoryProtocol,
    ) {
        
        // Sessions
        self.userSession = userSession
        self.listSession = listSession
        self.settingSession = settingSession
        self.cardSession = cardSession
        self.playSession = playSession
        
        // UIState
        self.colorUIState = ColorUIState()
        
        self.userActions = UserViewModel(
            repository: userRepository,
            session: userSession
        )
        self.listActions = ListViewModel(
            repository: listRepository,
            session: listSession,
            userSession: userSession
        )
        self.cardActions = CardViewModel(
            repository: cardRepository,
            session: cardSession,
            userSession: userSession,
            listSession: listSession
        )
        self.playActions = PlayViewModel(
            playSession: playSession,
            cardSession: cardSession,
            listSession: listSession,
            settingSession: settingSession,
            colorState: colorUIState,
            uiRepository: playRepository
        )
        self.loginActions = LoginViewModel(
            repository: userRepository,
            session: userSession
        )
    }
}
