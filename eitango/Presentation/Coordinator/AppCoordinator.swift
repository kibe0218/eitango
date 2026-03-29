import SwiftUI

extension RootViewModel {
    
    // ルート画面を丸ごと差し替え
    
    func moveToSplash() {
        print("🟡 moveToSplash 呼ばれたっピ")
        Task { @MainActor in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(
                    rootView: SplashScreenView()
                        .environmentObject(self)
                        .environmentObject(appState)
                )
                window.makeKeyAndVisible()
            }
        }
    }

    func moveToLoginView() {
        print("🟡 moveToStartView 呼ばれたっピ")
        Task { @MainActor in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(
                    rootView: LoginView()
                        .environmentObject(self)
                        .environmentObject(appState)
                )
                window.makeKeyAndVisible()
            }
        }
    }
    
}
