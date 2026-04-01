import Foundation
import Combine
import SwiftUI

class KeyboardObserver: ObservableObject{
    @Published var keyboardHeight: CGFloat = 0
    private var cancellable: AnyCancellable?
    init() {
        cancellable = Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
                .map { height in
                    print("🟡 keyboard will show height:", height)
                    return height.height
                },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in
                    print("🟡 keyboard hidden")
                    return CGFloat(0)
                }
        )
        .assign(to: \.keyboardHeight, on: self)
    }
}
