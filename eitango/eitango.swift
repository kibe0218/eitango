import SwiftUI
import CoreData
import Firebase

@main
struct eitangoApp: App {
    @StateObject private var vm = CompositionRoot.build()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if vm.userSession.user != nil {
                LoginView()
                    .environmentObject(vm)
            }
            else {
                SplashScreenView()
                    .environmentObject(vm)
            }
        }
    }
}
