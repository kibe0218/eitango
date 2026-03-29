import Foundation

struct AuthUseCase {
    func resolveAuthMethod(identifier: String, password: String) -> ValidateResult {
        if UserValidator.isValidUsername(identifier) != nil {
            print("🟡 username")
            return .success(LoginInput(identifier: identifier, password: password, method: .userName))
        } else if UserValidator.isValidPhoneNumber(identifier) != nil {
            print("🟡 phoneNumber")
            return .success(LoginInput(identifier: identifier, password: password, method: .phoneNumber))
        } else if UserValidator.isValidEmail(identifier) != nil {
            print("🟡 email")
            return .success(LoginInput(identifier: identifier, password: password, method: .email))
        } else {
            print("🟡 unknown")
            return .failure
        }
    }
}
