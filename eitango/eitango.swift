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
            if vm.userSession.user == nil {
                NavigationStack(path: $vm.authPath) {
                    LogInView()
                        .navigationDestination(for: AuthScreen.self) { screen in
                            switch screen {
                            case .signUp:
                                SignUpView()
                            }
                        }
                        .environmentObject(vm)
                }
            } else {
                HomeView()
            }
        }
        .environmentObject(vm)
        .environmentObject(vm.appState)
        .environmentObject(vm.colorUIState)
        .environmentObject(vm.keyboard)
    }
}
