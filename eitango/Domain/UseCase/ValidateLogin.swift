import Foundation

struct ValidateUserInputUseCase {
    func execute (
        
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
