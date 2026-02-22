import SwiftUI
import CoreData
import Firebase
import FirebaseAuth

@main
struct eitangoApp: App {
    
    @StateObject private var vm = RootViewModel()
    @StateObject private var session = UserSession()
    
    init() {
        FirebaseApp.configure()
        if let currentUid = Auth.auth().currentUser?.uid {
            session.userId = currentUid
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if session.userId != nil {
                StartView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .environmentObject(vm)
                    .environmentObject(vm.keyboard)
            }
            else {
                SplashScreenView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .environmentObject(vm)
                    .environmentObject(vm.keyboard)
            }
        }
    }
}
