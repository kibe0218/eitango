struct CompositionRoot {
    
    static func build() -> RootViewModel {
        
        let colorUIState = ColorUIState()
        // Session
        let userSession = UserSession()
        let listSession = ListSession()
        let cardSession = CardSession()
        let settingSession = SettingSession()
        let playSession = PlaySession()
        
        // Repository
        let userRepository = UserRepository(
            authRepository: AuthRepository(),
            user_dbRepository: User_DataBaseRepository(),
            user_cdRepository: User_CoreDataRepository()
        )
        let listRepository = ListRepository(
            list_dbRepository: List_DataBaseRepository(),
            list_cdRepository: List_CoreDataRepository()
        )
        let cardRepository = CardRepository(
            card_dbRepository: Card_DataBaseRepository(),
            card_cdRepository: Card_CoreDataRepository(),
            card_translateRepository: Card_GoogleAppScriptTranslate()
        )
        let playRepository = PlayRepository(
            Play_cdRepository: Play_CoreDataRepository()
        )
        
        // UseCase
        let loginUseCase = LoginUseCase(
            userSession: userSession
        )
        
        // ViewModel
        let loginVM = LoginViewModel(
            repository: userRepository,
            session: userSession,
            useCase: loginUseCase
        )
        
        let userVM = UserViewModel(
            repository: userRepository,
            session: userSession
        )
        
        let listVM = ListViewModel(
            repository: listRepository,
            session: listSession,
            userSession: userSession
        )
        
        let cardVM = CardViewModel(
            repository: cardRepository,
            session: cardSession,
            userSession: userSession,
            listSession: listSession
        )
        
        let playVM = PlayViewModel(
            playSession: playSession,
            cardSession: cardSession,
            listSession: listSession,
            settingSession: settingSession,
            colorState: colorUIState,
            uiRepository: playRepository
        )
        
        let appState = AppState()
        
        return RootViewModel(
            userSession: userSession,
            listSession: listSession,
            cardSession: cardSession,
            settingSession: settingSession,
            playSession: playSession,
            colorUIState: colorUIState,
            appState: appState,
            userActions: userVM,
            listActions: listVM,
            cardActions: cardVM,
            playActions: playVM,
            loginActions: loginVM
        )
    }
}

