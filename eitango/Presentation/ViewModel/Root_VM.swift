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
    
    @Published var appState: AppState

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
        appState: AppState,
        userActions: UserViewModel,
        listActions: ListViewModel,
        cardActions: CardViewModel,
        playActions: PlayViewModel,
        loginActions: LoginViewModel,
    ) {
        
        // Sessions
        self.userSession = userSession
        self.listSession = listSession
        self.settingSession = settingSession
        self.cardSession = cardSession
        self.playSession = playSession
        
        // UIState
        self.colorUIState = colorUIState
        
        self.userActions = userActions
        self.listActions = listActions
        self.cardActions = cardActions
        self.playActions = playActions
        self.loginActions = loginActions
        
        self.appState = appState
    }
}
