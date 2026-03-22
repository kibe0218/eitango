import Foundation
import Combine
import SwiftUI

class KeyboardObserver: ObservableObject{
    @Published var keyboardHeight: CGFloat = 0
    private var cancellable: AnyCancellable?
    init() {
        cancellable = Publishers.Merge(
            // Mergeで二つの通知を一つに
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            // NotificationCenterでキーボード通知を監視
            // keyboardWillShowNotificationはキーボードが出てくる前の通知
            // publisherは配列やオブジェクトの変化を通知として流すpublisherに変換するメソッド
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            // CGRectがキーボードのフレーム
                .map { $0.height },
            // 高さを抽出,mapは変換メソッド
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                
            // keyboardWillHideNotificationはキーボードが閉じる前の通知
                .map { _ in CGFloat(0) }
            // キーボードが閉じたら０に
        )
        .assign(to: \.keyboardHeight, on: self)
        // assignはpublisherが流してきた値をオブジェクトのプロパティに自動で代入
    }
}
