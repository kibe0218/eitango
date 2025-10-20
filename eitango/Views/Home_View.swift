import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: PlayViewModel
    @State private var selection = 0
    
    
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .tabItem {  // タブのアイテム設定
                            Image(systemName: "pencil.and.ellipsis.rectangle")
                            Text("Edit")  // お気に入りタブのラベル
                        }
                        .tag(1)
                }
                .onChange(of: selection) {vm.updateView()}
                .onAppear{vm.updateView()}
            }
        }
    }
}
