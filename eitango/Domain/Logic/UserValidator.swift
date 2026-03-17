import Foundation

struct UserValidator {
    
    //ユーザーネームをチェック
    static func validateUsername(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              trimmed.count <= 4
        else { return nil }
        for ch in trimmed {
            if ch.isEmoji { continue }
            if ch.isLetter || ch.isNumber { continue }
            return nil
        }
        return trimmed
    }
    
    // メアドをチェック
    static func isValidEmail(_ email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern =
        #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        guard !trimmed.isEmpty,
              trimmed.range(of: pattern, options: .regularExpression) != nil
        else {
            return nil
        }
        return trimmed
    }
    
    // パスワードをチェック
    static func isValidPassword(_ password: String) -> String? {
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              trimmed.count >= 10, trimmed.count <= 64,
              trimmed.rangeOfCharacter(from: .letters) != nil,
              trimmed.rangeOfCharacter(from: .decimalDigits) != nil
        else { return nil }
        return trimmed
    }
    
    // 最終判定
   private func validateInputs(
        selectedOption:
   ) -> Bool {
       var valid = true
       
       if selectedOption == "新規作成" {
           if isValidUsername(user) == nil {
               danger_user = true
               focusedField = .user
               valid = false
           } else {
               danger_user = false
           }
       }
       
       if isValidEmail(email) == nil {
           danger_email = true
           focusedField = .email
           valid = false
       } else {
           danger_email = false
       }
       
       if isValidPassword(pass) == nil {
           danger_pass = true
           focusedField = .pass
           valid = false
       } else {
           danger_pass = false
       }
       
       return valid
   }
    
}


