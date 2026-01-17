import SwiftUI

extension PlayViewModel {
    
    func addUserFrow(email: String, password: String, name: String) {
        addUserAuth(email: email, password: password, name: name) { [weak self] uid in
            guard let self else { return }
            if let uid {
                print("🟡Auth登録成功 uid =", uid)
                self.addUserAPI(name: name, id: uid)
            } else {
                print("🟡Auth失敗")
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
    
    
}
