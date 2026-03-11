import SwiftUI
import CoreData
import Firebase

@main
struct eitangoApp: App {
    @StateObject private var vm = RootViewModel(
        userSession: UserSession(),
        listSession: ListSession(),
        settingSession: SettingSession(),
        cardSession: CardSession(),
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
            card_cdRepository: Card_CoreDataRepository()
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
            if session.userId != nil {
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
