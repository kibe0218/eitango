import SwiftUI
import FirebaseAuth

//全体
enum AppState {
    case none
    case loggedIn
    case launching
    case loggedOut
    case onboarding
    case error(String)
}

enum AppFlow {
    case none
    case addingUser
    case loggingIn
    case signingUp
    case loggingOut
    case deletingUser
}

//状態管理プロトコル
protocol StateProtocol {
    associatedtype Func
    associatedtype Err: Error
    
    var stateCase: StateCase<Func, Err> { get }
}

enum StateCase<F, E: Error> {
    case idle
    case loading(F)
    case success(F)
    case failed(F?, E)
}

//データベース
struct DBStateStruct: StateProtocol {
    typealias Func = DBFunc
    typealias Err = DBError
    
    var stateCase: StateCase<DBFunc, DBError>
}

enum DBFunc {
    case fetchUser
    case fetchUserFromCoreData
    case addUserAPI
    case deleteUserAPI
}

//認証
struct AuthStateStruct: StateProtocol {
    typealias Func = AuthFunc
    typealias Err = AuthError
    
    var stateCase: StateCase <AuthFunc, AuthError>
}

enum AuthFunc {
    case addUserAuth
    case loginUserAuth
    case logoutUserAuth
    case deleteUserAuth
}

