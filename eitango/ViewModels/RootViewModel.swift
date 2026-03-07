import SwiftUI
import Combine
import CoreData

class KeyboardObserver: ObservableObject{
    @Published var keyboardHeight: CGFloat = 0
    private var cancellable: AnyCancellable?
    init() {
        cancellable = Publishers.Merge(
            //Mergeで二つの通知を一つに
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            //NotificationCenterでキーボード通知を監視
            //keyboardWillShowNotificationはキーボードが出てくる前の通知
            //defautはNotificationCetnerの標準的なインスタンスを指している
            //publisherは配列やオブジェクトの変化を通知として流すpublisherに変換するメソッド
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            //CGRectがキーボードのフレーム
            //compactMapは変換した値を確認してnilを弾く
                .map { $0.height },
            //高さを抽出,mapは変換メソッド
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            //keyboardWillHideNotificationはキーボードが閉じる前の通知
                .map { _ in CGFloat(0) }
            //キーボードが閉じたら０に
        )
        .assign(to: \.keyboardHeight, on: self)
        //assignはpublisherが流してきた値をオブジェクトのプロパティに自動で代入
    }
}

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
    @Published var setting: Setting_ST
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
