import SwiftUI
import FirebaseAuth

extension PlayViewModel{
    
    //=========
    //新規作成➕
    //=========
    
    func addUser(
        email: String,
        password: String,
        name: String
    ) {
        print("🟡 addUser 呼ばれたっピ")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Authエラー",error)
                return
            }
            
            guard let uid = result?.user.uid else {return}
            self.addUserAPI(name: name, id: uid) { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.fetchUser(userId: uid)
                        self.moveToSplash()
                    }
                case .failure(let error):
                    print("API登録失敗:", error)
                }
            }
        }
    }
    
    //========
    //ログイン📲
    //========
    
    func loginUser(
        email: String,
        password: String
    ) {
        print("🟡 loginUser 呼ばれたっピ")
        print("🟡 email =", email)
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if let error = error {
                print("Authエラー",error)
                return
            }
            guard let uid = result?.user.uid else {return}
            print("🟡 Firebase Auth.uid =", uid)
            DispatchQueue.main.async {
                print("🟡 vm.userid にセット =", self.userid)
                self.fetchUser(userId: uid)
                self.moveToSplash()
            }
        }
    }
    
    //==========
    //ログアウト⛔️
    //==========
    
    func logoutUser() {
        do {
            try Auth.auth().signOut()
            self.User = nil
            self.userid = ""
            self.moveToStartView()
            print("🟡ログアウト完了")
        } catch let error {
            print("🟡ログアウト失敗:", error)
        }
    }
    
    //=========
    //画面遷移📺
    //=========
    
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
