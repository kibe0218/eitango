import SwiftUI
import Combine
import CoreData

final class RootViewModel: ObservableObject {
    
    // App-wide UI state (View は基本これだけを見る)
    @Published var colorUIState: ColorUIState
    
    // App-wide helpers
    @Published var keyboard = KeyboardObserver()

    // App-wide sessions (View は直接見ない前提 / Actions が参照)
    let userSession: UserSession
    let listSession: ListSession
    let settingSession: SettingSession
    let cardSession: CardSession
    
    // Actions / Feature ViewModels (UIState を更新する側)
    let playActions: PlayViewModel
    let userActions: UserViewModel
    let listActions: ListViewModel
    let cardActions: CardViewModel
    let colorActions: ColorViewModel
    
    init(
        playSession: PlaySession,
        userSession: UserSession,
        listSession: ListSession,
        settingSession: SettingSession,
        cardSession: CardSession,
        colorUIState: ColorUIState,
        userRepository: UserRepositoryProtocol,
        listRepository: ListRepositoryProtocol,
        cardRepository: CardRepositoryProtocol,
        playRepository: PlayRepositoryProtocol,
        colorActions: ColorViewModel
    ) {
        
        self.playActions = PlayViewModel(
            playSession: playSession,
            cardSession: cardSession,
            listSession: listSession,
            settingSession: settingSession,
            colorState: colorUIState,
            uiRepository: playRepository
        )
        // Sessions
        self.userSession = userSession
        self.listSession = listSession
        self.settingSession = settingSession
        self.cardSession = cardSession

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
            userSession: userSession
        )
        
        self.colorUIState = ColorUIState()

        self.colorActions = ColorViewModel(
            state: colorUIState
        )
    }
}
