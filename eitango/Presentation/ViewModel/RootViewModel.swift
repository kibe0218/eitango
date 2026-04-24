import SwiftUI
import CoreData
import Combine

final class RootViewModel: ObservableObject {
    
    // App-wide UI state (View は基本これだけを見る)
    @Published var colorUIState: ColorUIState
    
    // App-wide helpers
    @Published var keyboard = KeyboardObserver()
    
    // Screen Observer
    @Published var path: [Screen] = []
    
    /// 画面は `@EnvironmentObject` で受け取る。ここは Coordinator や `environmentObject` 連鎖用に同一参照を保持する。
    let appState: AppState

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
    var authActions: AuthViewModel


    init(
        userSession: UserSession,
        listSession: ListSession,
        cardSession: CardSession,
        settingSession: SettingSession,
        playSession: PlaySession,
        colorUIState: ColorUIState,
        appState: AppState,
        authActions: AuthViewModel,
        userActions: UserViewModel,
        listActions: ListViewModel,
        cardActions: CardViewModel,
        playActions: PlayViewModel,
        
    ) {
        
        // Sessions
        self.userSession = userSession
        self.listSession = listSession
        self.settingSession = settingSession
        self.cardSession = cardSession
        self.playSession = playSession
        
        // UIState
        self.colorUIState = colorUIState
        self.appState = appState
        
        // ViewModel
        self.authActions = authActions
        self.userActions = userActions
        self.listActions = listActions
        self.cardActions = cardActions
        self.playActions = playActions
        
        
    }
}
