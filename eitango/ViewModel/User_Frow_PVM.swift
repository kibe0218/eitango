import SwiftUI

extension PlayViewModel {
    
    func addUserFrow(email: String, password: String, name: String) {
        addUserAuth(email: email, password: password, name: name) { [weak self] uid in
            guard let self else { return }
            if let uid {
                print("🟡addAuth登録成功 uid =", uid)
                Task {
                    await self.addUserAPI(name: name, id: uid)
                }
            } else {
                print("🟡addAuth失敗")
            }
        }
    }
    
    func deleteUserFrow() {
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
    
    func loginUserFrow(email: String, password: String) {
        loginUserAuth(email: email, password: password) { [weak self] uid in
            guard let self else { return }
            if let uid {
                print("🟡loginAuth登録成功 uid =", uid)
                Task {
                    await self.fetchUser(userId: uid)
                    self.fetchAllToCoreData()
                }
            } else {
                print("🟡loginAuth失敗")
            }
        }
            
    }
    
    func logoutUserFrow() {
        logoutUserAuth()
    }
    
}
