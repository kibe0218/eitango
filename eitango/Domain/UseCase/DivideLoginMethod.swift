import Foundation

struct LoginUseCase {
    
    private let userSession: UserSession

    init(
        userSession: UserSession,
    ) {
        self.userSession = userSession
    }
    
    func divideLoginMethod(identifier: String, password: String) -> ValidateResult {
        
        if UserValidator.isValidUsername(identifier) != nil {
            return .success(LoginInput(identifier: identifier, password: password, method: .userName))
        } else if UserValidator.isValidPhoneNumber(identifier) != nil {
            return .success(LoginInput(identifier: identifier, password: password, method: .phoneNumber))
        } else if UserValidator.isValidEmail(identifier) != nil {
            return .success(LoginInput(identifier: identifier, password: password, method: .email))
        } else {
            return .failure(.identifier)
        }
    }
}
