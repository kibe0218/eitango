import SwiftUI
import CoreData
import Firebase

@main
struct eitangoApp: App {
    @StateObject private var vm = PlayViewModel()
    @StateObject var keyboard = KeyboardObserver()
    
    init() {
        FirebaseApp.configure()
    }

    
    var body: some Scene {
        WindowGroup {
            UserView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(vm)
                .environmentObject(keyboard)
        }
    }
}

