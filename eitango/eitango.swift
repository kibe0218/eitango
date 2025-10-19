import SwiftUI
import CoreData

@main
struct eitangoApp: App {
    @StateObject private var vm = PlayViewModel()
    let persistenceController = PersistenceController()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(vm)
        }
    }
}
