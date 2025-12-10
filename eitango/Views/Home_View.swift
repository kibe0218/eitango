import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: PlayViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selection = 0
    @StateObject var keyboard = KeyboardObserver()

    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                TabView(selection: $selection) {  // タブビューを作成
                    PlayView()
                        .environmentObject(vm)
                        .tabItem { // タブのアイテム設定
                            Image(systemName: "play") // 家のアイコン
                            Text("Play") // ホームタブのラベル
                        }
                        .tag(0)
                    EditView()
                        .environmentObject(vm)
                        .environmentObject(keyboard)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .tabItem {  // タブのアイテム設定
                            Image(systemName: "pencil.and.ellipsis.rectangle")
                            Text("Edit")  // お気に入りタブのラベル
                        }
                        .tag(1)
//                    DogView()
//                        .environmentObject(vm)
//                        .tabItem {
//                            Image(systemName: "dog")
//                            Text("Dog")
//                        }
//                        .tag(2)
                }
                .accentColor(vm.customaccentColor)
                .onChange(of: selection) {vm.updateView()}
                .onAppear{
                    vm.updateView()
                    vm.colorS = colorScheme
                }
            }
        }
    }
}
