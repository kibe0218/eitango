import SwiftUI
import CoreData

@main
struct eitangoApp: App {
    @StateObject private var vm = PlayViewModel()
    @StateObject var keyboard = KeyboardObserver()
    let persistenceController = PersistenceController()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(vm)
                .environmentObject(keyboard)
        }
    }
}
