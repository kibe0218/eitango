import SwiftUI
import CoreData
import Firebase

@main
struct eitangoApp: App {
    
    @StateObject private var vm = RootViewModel()
    
    init() {
        FirebaseApp.configure()
        let currentUserId: String? = try await AuthRepository().currentUser()?.uid
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
