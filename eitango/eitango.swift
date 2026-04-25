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
            Group {
                if vm.userSession.user == nil {
                    NavigationStack(path: $vm.authPath) {
                        LogInView()
                            .navigationDestination(for: AuthScreen.self) { screen in
                                switch screen {
                                case .signUp:
                                    SignUpView()
                                case .emailSignUp:
                                    EmailSignUpView()
                                }
                            }
                    }
                    .environmentObject(vm)                }
                else {
                    SplashScreenView()
                }
            }
            .onAppear {
                print("🟡 RootView表示された")
                print("🟡 user:", vm.userSession.user as Any)
                vm.userActions.fetch()
            }
        }
        .environmentObject(vm)
        .environmentObject(vm.appState)
        .environmentObject(vm.colorUIState)
        .environmentObject(vm.keyboard)
    }
}
