import Foundation

struct ValidateIdentifierUseCase {
    
    private let userSession: UserSession

    init(
        userSession: UserSession,
    ) {
        self.userSession = userSession
    }
    
    func validate (
        identifier: String,
    ) -> LoginMethod? {
        
        if UserValidator.isValidUsername(identifier) != nil {
            return .userName(identifier)
        } else if UserValidator.isValidPhoneNumber(identifier) != nil {
            return .phoneNumber(identifier)
        } else if UserValidator.isValidEmail(identifier) != nil {
            return .email(identifier)
        } else {
            return nil
        }
    }
}
