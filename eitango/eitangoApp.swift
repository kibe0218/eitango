import SwiftUI

@main
struct eitangoApp: App {
    @StateObject private var vm = PlayViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(vm)
        }
    }
}
