//================================================
// 🧠 PlayViewModel
//================================================
//
// 【役割】
// ・📡 アプリ全体の状態を一元管理する中核 ViewModel
// ・🧩 各 PVM（Card / List / Color / Settings / UIUpdate / Flips）の集合体
// ・🖥 SwiftUI View から唯一参照される状態コンテナ
//
// 【責務】
// ・@Published による UI への状態配信
// ・各機能 PVM の関数を束ねて提供
// ・初期化時に「設定 → 色 → データ → 画面」の順で準備
//
// 【基本フロー】
// ① init() で ColorSetting() を実行
// ② loadSettings() で CoreData 設定を復元
// ③ updateView() で画面状態を初期構築
// ④ UI はこの ViewModel のみを監視
//
// 【設計方針】
// ・View はロジックを持たず、PlayViewModel のみを見る
// ・状態はできるだけここに集約し、分割 PVM は extension で構成
// ・「ViewModel が世界、View は鏡」という思想
//
// 【注意】
// ⚠️ このファイルは薄く保ち、処理は各 *_PVM.swift に分離する
// ⚠️ @Published 追加時は UI 影響範囲を必ず確認する
//
//================================================
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

final class PlayViewModel: ObservableObject {
    
    @Published var keyboard = KeyboardObserver() // ← ここ追加

    // 画面表示用の一時的なリスト
    @Published var Enlist: [String] = []
    @Published var Jplist: [String] = []
    @Published var isFlipped: [Bool] = [false, false, false, false]
    @Published var Finishlist: [Bool] = [false, false, false, false]

    // 保持用リスト
    @Published var Lists: [ListEntity] = []
    @Published var Cards: [CardEntity] = []
    @Published var User: UserEntity?
    
    @Published var enbase: [String] = []
    @Published var jpbase: [String] = []
    @Published var mistakecardlist: [(en: String, jp: String)] = []
    
    @Published var selectedListId: String?
    @Published var userid: String = ""
    @Published var userName: String = ""
    
    @Published var waittime = 2
    @Published var yy = 0
    @Published var jj = 0
    @Published var colortheme = 1
    
    @Published var title = ""
    
    // フラグ系
    @Published var finish = false
    @Published var cancelFlag = false
    @Published var reverse = false
    @Published var shuffleFlag: Bool = false
    @Published var noshuffleFlag: Bool = false
    @Published var repeatFlag: Bool = false
    @Published var showNotification: Bool = false
    @Published var showToast: Bool = false
    
    // 色
    @Published var colorS: ColorScheme = .light
    @Published var cardColor: Color = Color(hex:"cc7a6b").opacity(0.4)
    @Published var backColor: Color = Color(hex:"f8e8d3")
    @Published var customaccentColor: Color = Color(hex: "8b2f3c")
    @Published var noaccentColor: Color = Color.gray
    @Published var cardfrontColor: Color = Color.black
    @Published var cardbackColor: Color = Color(hex:"7b2b36")
    @Published var toggleColor: Color = Color(hex: "8b2f3c")
    @Published var cardlistColor: Color = Color(hex: "cc7a6b").opacity(0.6)
    @Published var cardlistmobColor: Color = Color(hex: "cc7a6b").opacity(0.25)
    @Published var textColor: Color = .primary
    
    // URL
    @Published var urlsession = "http://"+"172.20.10.4"+":8080/"
    
    //エラー管理
    @Published var authState: AuthState = .idle {
        didSet {
            updateAppState()
        }
    }
    @Published var userState: UserState = .idle {
        didSet {
            updateAppState()
        }
    }
    @Published var appState: AppState = .none
    @Published var currentFlow: AppFlow = .none
    fileprivate var previousStableState : AppState = .loggedOut
    
    private let repository = UserRepository(
        baseURL: "http://172.20.10.4:8080/"
    )

    //初期処理
    init() {
        ColorSetting()
        loadSettings()
        self.User = self.fetchUserFromCoreData()
        self.userid = self.User?.id ?? ""
        self.userName = self.User?.name ?? ""
    }
}
