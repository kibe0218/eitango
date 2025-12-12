import SwiftUI
import Combine
import CoreData

class KeyboardObserver: ObservableObject{
    @Published var keyboardHeight: CGFloat = 0
    private var cancellable: AnyCancellable?
    //キーボード通知を監視するパイプラインを購読するときに必要
    
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
    
    @Published var Enlist: [String] = []
    @Published var Jplist: [String] = []
    @Published var Finishlist: [Bool] = [false, false, false, false]
    @Published var tangotyou: [String] = []
    @Published var cards: [CardEntity] = []
    @Published var enbase: [String] = []
    @Published var jpbase: [String] = []
    @Published var mistakecardlist: [(en: String, jp: String)] = []
    
    @Published var number  = 0
    @Published var waittime = 2
    @Published var yy = 0
    @Published var jj = 0
    @Published var colortheme = 1
    
    @Published var title = ""
    
    @Published var isFlipped: [Bool] = [false, false, false, false]
    @Published var finish = false
    @Published var cancelFlag = false
    @Published var reverse = false
    @Published var shuffleFlag: Bool = false
    @Published var noshuffleFlag: Bool = false
    @Published var repeatFlag: Bool = false
    @Published var numberFlag: Bool = false
    @Published var showNotification: Bool = false
    @Published var showToast: Bool = false
    
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
    
    
    init() {
        ColorSetting()
        loadSettings()
        numberFlag = true
        updateView()
        //repeatingで繰り返し配列にaddする
        
    }
        
}
