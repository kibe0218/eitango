import SwiftUI
import Combine
import CoreData

final class RootViewModel: ObservableObject {
    
    // App-wide UI state (View は基本これだけを見る)
    @Published var uiState: PlayUIState

    // App-wide sessions (View は直接見ない前提 / Actions が参照)
    let userSession: UserSession
    let listSession: ListSession
    let settingSession: SettingSession
    let cardSession: CardSession

    // App-wide helpers
    @Published var keyboard = KeyboardObserver()

    // Actions / Feature ViewModels (UIState を更新する側)
    let playActions: PlayViewModel
    let userActions: UserViewModel
    let listActions: ListViewModel

    init(
        uiState: RootUIState = RootUIState(),
        userSession: UserSession = UserSession(),
        listSession: ListSession = ListSession(),
        settingSession: SettingSession = SettingSession(),
        cardSession: CardSession = CardSession(),
        playEngine: SessionEngine = SessionEngine()
    ) {
        self.uiState = uiState
        self.userSession = userSession
        self.listSession = listSession
        self.settingSession = settingSession
        self.cardSession = cardSession

        // Play actions
        self.playActions = ActionViewModel(
            cardSession: cardSession,
            uiState: uiState.playUIState,
            engine: playEngine
        )

        // Auth / User actions
        let authRepository = AuthRepository()
        let userDbRepository = User_DataBaseRepository(session: userSession)
        let userCdRepository = User_CoreDataRepository()
        let userRepository: UserRepositoryProtocol =
            (try? UserRepository(
                authRepository: authRepository,
                user_dbRepository: userDbRepository,
                user_cdRepository: userCdRepository
            )) ?? UnavailableUserRepository()
        self.authActions = UserViewModel(userRepository: userRepository)

        // List actions
        let listDbRepository = List_DataBaseRepository(session: userSession)
        let listCdRepository = List_CoreDataRepository()
        let listRepository: ListRepositoryProtocol =
            (try? ListRepository(
                list_dbRepository: listDbRepository,
                list_cdRepository: listCdRepository
            )) ?? UnavailableListRepository()
        self.listActions = ListViewModel(listRepository: listRepository)
    }
}
