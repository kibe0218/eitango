import SwiftUI

//順番だけ保証
extension PlayViewModel {
    
    func Add(email: String, password: String, name: String) {
        Task {
            do {
                let result = try await addUserAuth(email: email, password, name: name)
            }
        }
        currentFlow = .addingUser
        addUserAuth(email: email, password: password, name: name) { [weak self] uid in
            guard let self else {
                print("🟡Flow中断: ViewModelが破棄された")
                return
            }
            
            if let uid {
                print("🟡addAuth登録成功 uid =", uid)
                Task {
                    await self.addUserAPI(name: name, id: uid)
                    self.reinit()
                    self.moveToSplash()
                }
            } else {
                print("🟡addAuth失敗")
            }
        }
    }
    
    func Login(email: String, password: String) {
        loginUserAuth(email: email, password: password) { [weak self]
            uid in
            guard let self else { return }
            if let uid {
                Task {
                    await self.fetchUser(userId: uid)
                    self.reinit()
                }
                print("🟡loginAuth登録成功 uid =", uid)
            } else {
                print("🟡loginAuth失敗")
            }
        }
            
    }
    
    func Delete() {
        deleteUserAuth { [weak self] success in
            guard let self else { return }
            if success {
                print("🟡deleteauth成功")
                self.logoutUserAuth()
            } else {
                print("🟡deleteAuth失敗")
            }

        }
    }
    
    func Logout(email: String, password: String) {
        
        
    }
}
