import SwiftUI

extension PlayViewModel {
    
    func moveToSplash() {
        print("🟡 moveToSplash 呼ばれたっピ")
        Task { @MainActor in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(
                    rootView: SplashScreenView()
                        .environmentObject(self)
                )
                window.makeKeyAndVisible()
            }
        }
    }

    func moveToStartView() {
        print("🟡 moveToStartView 呼ばれたっピ")
        Task { @MainActor in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(
                    rootView: StartView()
                        .environmentObject(self)
                        .environmentObject(self.keyboard)
                )
                window.makeKeyAndVisible()
            }
        }
    }

    
}
