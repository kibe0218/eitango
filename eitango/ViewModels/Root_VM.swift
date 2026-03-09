import SwiftUI
import Combine
import CoreData



final class RootViewModel: ObservableObject {
    
    @Published var keyboard = KeyboardObserver()
    // フラグ系
    @Published var finish = false
    @Published var cancelFlag = false
    @Published var reverse = false
    @Published var shuffleFlag: Bool = false
    @Published var noshuffleFlag: Bool = false
    @Published var repeatFlag: Bool = false
    @Published var showNotification: Bool = false
    @Published var showToast: Bool = false
    @Published var showErrorAlert: Bool = false
    
    //設定
    @Published var setting: setting
    @Published var appState: AppState = .none
    
    @Published var currentFlow: AppFlow = .none
    fileprivate var previousStableState : AppState = .loggedOut
    
    let settingRepository: SettingRepositoryProtocol

    //初期処理
    init (
        settingRepository: SettingRepositoryProtocol = SettingRepository()
    ) throws {
        self.settingRepository = settingRepository
        
        self.setting = try settingRepository.fetch()
        self.User = try user_cdRepository.fetch()
        self.Lists = try list_cdRepository.fetch()
        ColorSetting()
    }
}
