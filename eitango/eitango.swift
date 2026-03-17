import SwiftUI
import CoreData
import Firebase

@main
struct eitangoApp: App {
    @StateObject private var vm = RootViewModel(
        userSession: UserSession(),
        listSession: ListSession(),
        cardSession: CardSession(),
        settingSession: SettingSession(),
        playSession: PlaySession(),
        colorUIState: ColorUIState(),
        userRepository: UserRepository(
            authRepository: AuthRepository(),
            user_dbRepository: User_DataBaseRepository(),
            user_cdRepository: User_CoreDataRepository(),
        ),
        listRepository: ListRepository(
            list_dbRepository: List_DataBaseRepository(),
            list_cdRepository: List_CoreDataRepository()
        ),
        cardRepository: CardRepository(
            card_dbRepository: Card_DataBaseRepository(),
            card_cdRepository: Card_CoreDataRepository(),
            card_translateRepository: Card_GoogleAppScriptTranslate()
        ),
        playRepository: PlayRepository(
            Play_cdRepository: Play_CoreDataRepository()
        )
    )
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if vm.userSession.user != nil {
                StartView()
                    .environmentObject(vm)
            }
            else {
                SplashScreenView()
                    .environmentObject(vm)
            }
        }
    }
}
